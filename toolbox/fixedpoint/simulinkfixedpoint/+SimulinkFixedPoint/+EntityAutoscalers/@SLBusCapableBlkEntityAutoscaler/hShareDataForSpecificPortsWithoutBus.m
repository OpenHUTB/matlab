function sharedListPorts=hShareDataForSpecificPortsWithoutBus(h,blkObj,inportSet,outportSet)





    sharedListPorts='';
    if~isempty(blkObj)
        hPorts=get_param(blkObj.Handle,'PortHandles');
        outportSet=removePortsWithBusSignals(outportSet,hPorts.Outport);
        sharedListPorts=hShareDTSpecifiedPorts(h,blkObj,inportSet,outportSet);
    end


    function portSetOut=removePortsWithBusSignals(portSet,hPorts)



        if isempty(portSet)
            portSetOut=[];
            return;
        end
        if isequal(-1,portSet)
            portSet=1:length(hPorts);
        end

        isBus=zeros(1,length(portSet));

        for i=1:length(portSet)
            portNumb=portSet(i);
            hport=hPorts(portNumb);
            compiledPortBusMode=get_param(hport,'CompiledPortBusMode');
            if isempty(compiledPortBusMode)
                continue;
            end
            if(compiledPortBusMode==1)
                isBus(i)=1;
            else
                isBus(i)=0;
            end
        end
        portSetOut=portSet(isBus==0);


