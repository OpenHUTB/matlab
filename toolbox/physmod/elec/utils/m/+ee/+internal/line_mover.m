function line_mover(block,oldPort,newPort)












    system=get_param(block,'Parent');
    portList=get_param(block,'PortHandles');
    numLConns=length(portList.LConn);

    if iscell(oldPort)
        oldPortHandle=cell(1,length(oldPort));
        newPortHandle=cell(1,length(oldPort));
        for idx=1:length(oldPort)
            if newPort{idx}<=numLConns
                oldPortHandle{idx}=portList.LConn(oldPort{idx});
                newPortHandle{idx}=portList.LConn(newPort{idx});
            else
                oldPortHandle{idx}=portList.RConn(oldPort{idx}-numLConns);
                newPortHandle{idx}=portList.RConn(newPort{idx}-numLConns);
            end
        end
        connections=get_param(block,'PortConnectivity');

        for idx=1:length(oldPort)
            dstPorts=connections(oldPort{idx}).DstPort;
            for i=1:length(dstPorts)
                if get_param(dstPorts(i),'Line')~=-1
                    delete_line(get_param(dstPorts(i),'Line'));
                end
            end
        end

        for idx=1:length(oldPort)
            dstPorts=connections(oldPort{idx}).DstPort;
            blockHandle=gcbh;
            dstBlocks=connections(oldPort{idx}).DstBlock;

            for i=1:length(dstPorts)
                if newPortHandle{idx}~=dstPorts(i)&&dstBlocks(i)~=blockHandle
                    try
                        add_line(system,newPortHandle{idx},dstPorts(i),'autorouting','on');
                    catch ME
                        if~strcmp(ME.identifier,'Simulink:Commands:AddLineSecondAlreadyConnected')
                            rethrow(ME)
                        end
                    end
                elseif dstBlocks(i)==blockHandle
                    for j=1:length(oldPortHandle)
                        if oldPortHandle{j}==dstPorts(i)
                            try
                                add_line(system,newPortHandle{idx},newPortHandle{j},'autorouting','on');
                            catch ME
                                if~strcmp(ME.identifier,'Simulink:Commands:AddLineSecondAlreadyConnected')
                                    rethrow(ME)
                                end
                            end
                            break
                        elseif j==length(oldPortHandle)

                            try
                                add_line(system,newPortHandle{idx},dstPorts(i),'autorouting','on');
                            catch ME
                                if~strcmp(ME.identifier,'Simulink:Commands:AddLineSecondAlreadyConnected')
                                    rethrow(ME)
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        if newPort<=numLConns
            newPortHandle=portList.LConn(newPort);
        else
            newPortHandle=portList.RConn(newPort-numLConns);
        end
        connections=get_param(block,'PortConnectivity');
        dstPorts=connections(oldPort).DstPort;
        for i=1:length(dstPorts)
            delete_line(get_param(dstPorts(i),'Line'));
        end
        for i=1:length(dstPorts)
            add_line(system,newPortHandle,dstPorts(i),'autorouting','on');
        end
    end