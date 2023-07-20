


function HbSrcPorts=getGrActualSrc(iPObj)

    HbSrcPorts=[];
    block=iPObj.Parent;
    portNumber=iPObj.PortNumber;

    portConnectivity=get_param(block,'PortConnectivity');
    opConnectivity=portConnectivity(portNumber);
    SrcBlock=opConnectivity.SrcBlock;

    SrcPortNumber=opConnectivity.SrcPort+1;



    portHandles=get_param(SrcBlock,'PortHandles');
    outPortHandles=portHandles.Outport;
    HbSrcPorts=outPortHandles(SrcPortNumber);

    HbSrcPorts=HbSrcPorts';
end
