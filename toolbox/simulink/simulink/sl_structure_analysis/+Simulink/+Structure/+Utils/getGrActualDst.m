


function HbDstPorts=getGrActualDst(oPObj)

    import Simulink.Structure.Utils.*

    HbDstPorts=[];
    block=oPObj.Parent;
    portNumber=oPObj.PortNumber;

    portHandles=get_param(block,'PortHandles');

    inPortHandles=getAllInportHandles(portHandles);

    m=length(inPortHandles);

    portConnectivity=get_param(block,'PortConnectivity');

    opConnectivity=portConnectivity(m+portNumber);
    DstBlock=opConnectivity.DstBlock;

    DstPortNumber=opConnectivity.DstPort;

    index=1;

    for i=1:length(DstBlock)
        portNumber=DstPortNumber(i);




        if round(portNumber)~=portNumber
            HbDstPorts(index)=portNumber;
            continue;
        else
            portNumber=portNumber+1;
        end

        DstBlockObj=get_param(DstBlock(i),'Object');

        portHandles=get_param(DstBlock(i),'PortHandles');
        inPortHandles=getAllInportHandles(portHandles);
        HbDstPorts(index)=inPortHandles(portNumber);

        isVirtualSubIn=strcmp(DstBlockObj.BlockType,'SubSystem')&&strcmp(DstBlockObj.IsSubsystemVirtual,'on');
        isVirtualSubOut=isVirtualSubSystemRootOutput(DstBlock(i));

        if(isVirtualSubIn||isVirtualSubOut)
            if isVirtualSubIn
                HbDst=getInsidePort(HbDstPorts(index));
            else
                HbDst=getOutsidePort(HbDstPorts(index));
            end

            HbDst=getGrActualDst(get_param(HbDst,'Object'));

            if isempty(HbDst)

                index=index+1;
            else

                HbDstPorts(index:index+length(HbDst)-1)=HbDst;
                index=index+length(HbDst);
            end
        else
            index=index+1;
        end
    end
    HbDstPorts=HbDstPorts';
end

