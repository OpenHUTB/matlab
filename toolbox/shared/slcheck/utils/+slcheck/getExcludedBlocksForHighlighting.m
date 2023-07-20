function[blocks,exclusionDetails]=getExcludedBlocksForHighlighting(system,checkID)





    blocks={};
    exclusionDetails={};


    manager=slcheck.getAdvisorFilterManager(system);
    exclusions=manager.filters;

    if~exclusions.Size
        return;
    end

    if ischar(checkID)
        checkID={checkID};
    end

    for i=1:exclusions.Size
        ex=exclusions(i);

        checks=ex.checks.toArray;
        if~ismember(checks,'.*')&&~ismember(checks,checkID)
            continue;
        end

        infoTable=ModelAdvisor.Table(1,4);
        infoTable.setColHeading(1,DAStudio.message('ModelAdvisor:engine:ExclusionRationale'));
        infoTable.setColHeading(2,DAStudio.message('ModelAdvisor:engine:ExclusionType'));
        infoTable.setColHeading(3,DAStudio.message('ModelAdvisor:engine:ExclusionValue'));
        infoTable.setColHeading(4,DAStudio.message('ModelAdvisor:engine:ExclusionCheckIDs'));
        infoTable.setEntry(1,1,['&nbsp;',ex.metadata.summary,'&nbsp;']);
        infoTable.setEntry(1,2,['&nbsp;',slcheck.getFilterTypeString(ex.type),'&nbsp;']);
        infoTable.setEntry(1,3,['&nbsp;',ex.id,'&nbsp;']);
        infoTable.setEntry(1,4,['&nbsp;',char(checks),'&nbsp;']);
        excludeMsg=infoTable.emitHTML;
        try


            switch ex.type
            case advisor.filter.FilterType.Block
                blocks{end+1}=ex.id;
                exclusionDetails{end+1}=excludeMsg;
            case advisor.filter.FilterType.BlockType
                blks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'blocktype',ex.id);
                if~isempty(blks)
                    blocks=[blocks;Simulink.ID.getSID(blks)];
                    for blkcnt=1:length(blks)
                        exclusionDetails{end+1}=excludeMsg;
                    end
                end
            case advisor.filter.FilterType.Subsystem
                blks=find_system(ex.id,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
                for j=1:length(blks)
                    blocks{end+1}=Simulink.ID.getSID(blks{j});
                    for blkcnt=1:length(blks)
                        exclusionDetails{end+1}=excludeMsg;
                    end
                end
            case advisor.filter.FilterType.MaskType
                masks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'masktype',ex.id);
                for j=1:length(masks)
                    blks=find_system(masks{j},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all');
                    for k=1:length(blks)
                        blocks{end+1}=Simulink.ID.getSID(blks{k});
                        exclusionDetails{end+1}=excludeMsg;
                    end
                end
            case advisor.filter.FilterType.Library
                libBlks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock',ex.id);
                for j=1:length(libBlks)
                    blks=find_system(libBlks{j},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'followlinks','on');
                    for k=1:length(blks)
                        blocks{end+1}=Simulink.ID.getSID(blks{k});
                        exclusionDetails{end+1}=excludeMsg;
                    end
                end
            end
        catch
            continue;
        end
    end
end