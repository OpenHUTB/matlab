function unconnectedPorts(systemHandle)







    blocks=find_system(systemHandle,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','BlockType','SubSystem');
    for idxBlock=1:numel(blocks)
        thisBlock=blocks{idxBlock};
        portConnectivity=get_param(thisBlock,'PortConnectivity');
        if isempty([portConnectivity.DstBlock])
            continue
        end

        allPortHandles=get_param(thisBlock,'PortHandles');
        physicalPortHandles=[allPortHandles.LConn,allPortHandles.RConn];
        for idx=1:numel(physicalPortHandles)
            thisPort=physicalPortHandles(idx);


            if get_param(thisPort,'Line')==-1
                portPosition=get_param(thisPort,'Position');
                [filePath,~,~]=fileparts(thisBlock);
                dest=fullfile(filePath,'open circuit');
                h=add_block('fl_lib/Electrical/Electrical Elements/Open Circuit',dest,'MakeNameUnique','on');
                temp=get_param(h,'PortHandles');
                newPortHandle=temp.LConn;
                set_param(h,'position',10+[portPosition,portPosition+[8,20]]);
                try
                    add_line(filePath,thisPort,newPortHandle,'autorouting','smart');
                catch
                    delete_block(h);
                end
            end
        end
    end

end