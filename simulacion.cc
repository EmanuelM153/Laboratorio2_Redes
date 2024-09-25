#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/dce-module.h"
#include "ns3/point-to-point-module.h"
#include <iostream>
#include <string>

#define DELAY "2ms"
#define IPERF_SIZE "2147483648"
#define SIMULATION_TIME 420

using namespace ns3;

int main (int argc, char *argv[])
{
    std::string dataRate;
    std::string captureFile;
    bool pingFlood = false;

    std::cout << "Data Rate: ";
    std::cin >> dataRate;

    std::cout << "Archivo de captura: ";
    std::cin >> captureFile;

    std::cout << "¿Deseas activar el flood ping para generar congestión? (s/n): ";
    char floodInput;
    std::cin >> floodInput;
    if (floodInput == 's' || floodInput == 'S')
        pingFlood = true;

    // Crear dos nodos
    NodeContainer nodes;
    nodes.Create(2);

    // Configurar enlace punto a punto con DataRate y Delay
    PointToPointHelper pointToPoint;
    pointToPoint.SetDeviceAttribute("DataRate", StringValue(dataRate + "Mbps"));
    pointToPoint.SetChannelAttribute("Delay", StringValue(DELAY));

    // Instalar dispositivos y canales en los nodos
    NetDeviceContainer devices = pointToPoint.Install(nodes);

    // Habilitar captura de tráfico en formato pcap
    pointToPoint.EnablePcap(captureFile, devices.Get(1), true);

    // Instalar la pila TCP/IP en los nodos
    InternetStackHelper stack;
    stack.Install(nodes);

    // Asignar direcciones IP a las interfaces
    Ipv4AddressHelper address;
    address.SetBase("10.1.1.0", "255.255.255.0");
    Ipv4InterfaceContainer interfaces = address.Assign(devices);

    // Save pointer to server's IPv4 instance, and IP interface index, for later
    std::pair<Ptr<Ipv4>, uint32_t> returnValue = interfaces.Get (1);
    Ptr<Ipv4> serverIpv4 = returnValue.first;
    uint32_t serverIndex = returnValue.second;

    // Instalar el administrador de DCE
    DceManagerHelper dceManager;
    dceManager.SetTaskManagerAttribute ("FiberManagerType", StringValue ("UcontextFiberManager"));
    dceManager.Install(nodes);

    // Configurar el enrutamiento global
    Ipv4GlobalRoutingHelper::PopulateRoutingTables();

    // -------- Configurar la aplicación DCE (iperf) --------
    ApplicationContainer apps;
    DceApplicationHelper dce;
    std::ostringstream serverIp;
    dce.SetStackSize(1 << 20);

    // Configurar iperf en el cliente (nodo 0) para enviar el archivo preexistente
    dce.SetBinary("iperf");
    dce.ResetArguments();
    dce.ResetEnvironment ();
    dce.AddArgument("-c");

    Ipv4Address serverAddress = serverIpv4->GetAddress (serverIndex, 0).GetLocal ();
    serverAddress.Print (serverIp);
    // Dirección del servidor
    dce.AddArgument(serverIp.str());

    dce.AddArgument("-n");
    dce.AddArgument(IPERF_SIZE);
    dce.AddArgument ("-i");
    dce.AddArgument ("1");
    apps = dce.Install(nodes.Get(0));
    apps.Start(Seconds(0.7));
    apps.Stop(Seconds(SIMULATION_TIME));

    // Configurar iperf en el servidor (nodo 2)
    dce.SetBinary("iperf");
    dce.ResetArguments();
    dce.ResetEnvironment ();
    dce.AddArgument("-s"); // Modo servidor
    dce.AddArgument ("-P");
    dce.AddArgument ("1");
    apps = dce.Install(nodes.Get(1));
    apps.Start(Seconds(0.6));

    // -------- Configurar flood ping para simular congestión --------
    if (pingFlood) {
        dce.SetBinary("ping");
        dce.ResetArguments();
        dce.AddArgument("-f"); // Modo flood ping
        dce.AddArgument("-s");
        dce.AddArgument("65507");  // Tamaño del paquete 1024 bytes
        dce.AddArgument(serverIp.str()); // Dirección de destino (nodo servidor)
        apps = dce.Install(nodes.Get(0));  // Ejecutar en el nodo cliente
        apps.Start(Seconds(3.0));  // Inicia después de iperf para generar congestión
        apps.Stop(Seconds(SIMULATION_TIME));  // Termina a los 360 segundos
    }

    // Ejecutar la simulación
    Simulator::Stop(Seconds(SIMULATION_TIME));
    Simulator::Run();
    Simulator::Destroy();

    return 0;
}
