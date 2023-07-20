function fcnCallGenEnablePort(obj)




    if isR2021aOrEarlier(obj.ver)
        fcGenBlks=find_system(obj.modelName,...
        'MatchFilter',@Simulink.match.allVariants,...
        'LookUnderMasks','on',...
        'IncludeCommented','on',...
        'BlockType','S-Function',...
        'MaskType','Function-Call Generator',...
        'FunctionName','fcgen',...
        'ReferenceBlock','simulink/Ports & Subsystems/Function-Call Generator');
        if isempty(fcGenBlks)
            return;
        end
        for bIdx=1:length(fcGenBlks)
            blk=fcGenBlks{bIdx};
            set_param(blk,'ShowEnablePort','off');
        end
    end

end
