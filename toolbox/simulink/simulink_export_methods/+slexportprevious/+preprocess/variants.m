function variants(obj)











    inheritVariantTrigPortBlocks=...
    find_system(obj.origModelName,...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'IncludeCommented','on',...
    'BlockType','TriggerPort',...
    'IsSimulinkFunction','on',...
    'Variant','on',...
    'VariantControl',Simulink.variant.keywords.getInheritVariantKeyword());

    if isR2017aOrEarlier(obj.ver)

        for ii=1:numel(inheritVariantTrigPortBlocks)


            blkParent=get_param(inheritVariantTrigPortBlocks{ii},'Parent');



            if strcmp(blkParent,obj.modelName),continue;end




            sldiagviewer.reportWarning(MException(message('Simulink:ExportPrevious:InheritVariantSimulinkFunctionBlock',blkParent,obj.origModelName)));
        end

    end

end


