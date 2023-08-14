function FIL(obj)





    blks=find_system(obj.modelName,'IncludeCommented','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'LookUnderMasks','all','FunctionName','filsfun');
    if isempty(blks)
        return;
    end

    if isR2011aOrEarlier(obj.ver)
        warning(message('EDALink:FILWorkflow:ExportPriorToR2011a'));

        for idx=1:length(blks)
            obj.replaceWithEmptySubsystem(blks{idx});
        end
    elseif isR2013bOrEarlier(obj.ver)

        warning(message('EDALink:FILWorkflow:ExportAfterR2011a'));
    end


