classdef DemStatusValidator






    methods(Static)
        function eventIds=getEventIds(modelName,demStatusBlks)
            function value=getValue(obj)
                if isobject(obj)&&isa(obj,'Simulink.Parameter')
                    value=obj.Value;
                else
                    value=obj;
                end
            end

            eventIds=cellfun(@(x)get_param(x,'EventId'),demStatusBlks,'UniformOutput',false);
            eventIds=cellfun(@(x)evalinGlobalScope(modelName,x),eventIds,'UniformOutput',false);
            eventIds=cellfun(@(x)getValue(x),eventIds,'UniformOutput',true);
            eventIds(isnan(eventIds))=0;
        end

        function verifyNoSharedEventIds(demStatusBlks)


            if isempty(demStatusBlks)
                return;
            end
            modelName=bdroot(demStatusBlks{1});

            demStatusEventIds=autosar.bsw.DemStatusValidator.getEventIds(modelName,demStatusBlks);


            [sortedEventIds,sortOrder]=sort(demStatusEventIds);
            sortedBlocks=demStatusBlks(sortOrder);


            [~,uniqueEventIdIdx,~]=unique(sortedEventIds,'first');



            duplicateIds=find(not(ismember(1:numel(sortedEventIds),uniqueEventIdIdx)));

            if~isempty(duplicateIds)
                id=duplicateIds(1);
                DAStudio.error('autosarstandard:bsw:OverrideTwice',getfullname(sortedBlocks{id-1}),getfullname(sortedBlocks{id}));
            end
        end

        function verifyNoDupeAndInject(demOverrideBlocks,demInjectBlocks)



            if isempty(demOverrideBlocks)||isempty(demInjectBlocks)
                return;
            end

            modelName=bdroot(demOverrideBlocks{1});

            overrideEventIds=autosar.bsw.DemStatusValidator.getEventIds(modelName,demOverrideBlocks);
            injectEventIds=autosar.bsw.DemStatusValidator.getEventIds(modelName,demInjectBlocks);

            shared=intersect(overrideEventIds,injectEventIds);
            if~isempty(shared)
                sharedId=shared(1);
                overrideBlk=demOverrideBlocks(overrideEventIds==sharedId);
                injectBlk=demInjectBlocks(injectEventIds==sharedId);
                DAStudio.error('autosarstandard:bsw:InjectAndOverride',getfullname(overrideBlk{1}),getfullname(injectBlk{1}));
            end
        end

        function verifyValidEventIds(demStatusBlks,eventIds)


            if isempty(demStatusBlks)
                return;
            end
            modelName=bdroot(demStatusBlks{1});

            demStatusEventIds=autosar.bsw.DemStatusValidator.getEventIds(modelName,demStatusBlks);

            [invalidIds,idx]=setdiff(demStatusEventIds,eventIds);
            if~isempty(invalidIds)
                DAStudio.error('autosarstandard:bsw:EventIdNotValid',getfullname(demStatusBlks{idx}))
            end
        end

        function verifyServiceComponentPresent(blkPath)

            if slsvTestingHook('SuppressDemStatusDSCReq')

                return;
            end
            modelName=bdroot(blkPath);
            if~autosar.validation.CompiledModelUtils.isCompiled(bdroot(blkPath))

                return;
            end
            serviceComp=autosar.bsw.ServiceComponent.find(modelName);
            if isempty(serviceComp)...
                ||~any(cellfun(@(x)strcmp(get_param(x,'MaskType'),...
                autosar.bsw.ServiceComponent.DemServiceBlockMaskType),serviceComp))
                DAStudio.error('autosarstandard:bsw:NoDiagnosticServiceComponent',getfullname(blkPath));
            end
        end

        function[demOverrideBlocks,demInjectBlocks]=findDemStatusBlocks(modelName)


            demOverrideBlocks=find_system(modelName,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on','MaskType','DemStatusOverride');
            demInjectBlocks=find_system(modelName,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on','MaskType','DemStatusInject');
        end
    end
end


