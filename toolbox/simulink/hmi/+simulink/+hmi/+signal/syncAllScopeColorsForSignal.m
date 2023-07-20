function syncAllScopeColorsForSignal(client)






    si=client.SignalInfo;
    blk=si.BlockPath.getBlock(si.BlockPath.getLength());
    hBlks=Simulink.HMI.getDashboardBlocksForBoundElement(blk);
    for idx=1:numel(hBlks)
        locUpdateBlock(hBlks(idx),si,client);
    end
end


function locUpdateBlock(hBlk,si,client)
    if strcmpi(get_param(hBlk,'BlockType'),'DashboardScope')
        bindings=get_param(hBlk,'Binding');
        clrs=get_param(hBlk,'Colors');
        numBindings=numel(bindings);
        for idx=1:numel(clrs)
            if idx<=numBindings
                if bindings{idx}.OutputPortIndex==si.OutputPortIndex&&...
                    isequal(bindings{idx}.BlockPath,si.BlockPath)
                    if~isequal(clrs(idx).Color,client.ObserverParams.LineSettings.Color)||...
                        ~isequal(clrs(idx).LineStyle,client.ObserverParams.LineSettings.LineStyle)
                        clrs(idx).Color=client.ObserverParams.LineSettings.Color;
                        clrs(idx).LineStyle=client.ObserverParams.LineSettings.LineStyle;
                        set_param(hBlk,'Colors',clrs);
                    end
                end
            end
        end
    end
end
