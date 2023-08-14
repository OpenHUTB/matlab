classdef(Hidden)IOBlockSemantics<handle




    methods(Static)
        function verifyBlockInFcnCallSubsystem(blkFullName)







            subsysName=locGetSecondParentFromTop(blkFullName);


            trigPort=find_system(subsysName,'FirstResultOnly','on','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','TriggerPort');
            if isempty(trigPort)&&...
                ~isequal(get_param(subsysName,'ScheduleAs'),'Aperiodic partition')
                MSLE=MSLException(get_param(blkFullName,'handle'),...
                message('soc:utils:IOBlkNotInFcnCall',...
                getfullname(blkFullName)));
                throwAsCaller(MSLE);
            end
        end

        function verifyBlockInEventDrivenTask(blkFullName)












            soc.internal.IOBlockSemantics.verifyBlockInFcnCallSubsystem(blkFullName);
            refModel=bdroot(blkFullName);

            soc.internal.ESBRegistry.manageInstance('get',refModel);
            reg=soc.internal.ESBRegistry.manageInstance(...
            'getfullmodelreferencehierarchy',refModel);
            allLoadedModels=reg.AllRefModels(cellfun(@(x)bdIsLoaded(x),...
            reg.AllRefModels));
            assertIfTaskMgrNotFound=false;
            tskMgr=soc.internal.connectivity.getTaskManagerBlock(...
            allLoadedModels,assertIfTaskMgrNotFound);
            if isempty(tskMgr)

                return
            elseif iscell(tskMgr)
                tskMgr=tskMgr{1};
            end
            topModel=bdroot(tskMgr);
            MSLE=MSLException([],message('soc:utils:IOBlkNotInEventDrivenFcn',...
            getfullname(blkFullName),getfullname(tskMgr)));
            try
                [~,eventName]=soc.internal.connectivity.getTaskNameForFcnCallSubs(...
                get_param(blkFullName,'handle'),topModel);
            catch ME
                throwAsCaller(MSLE);
            end
            if isempty(eventName)
                throwAsCaller(MSLE);
            end
        end
    end
end


function ret=locGetSecondParentFromTop(sys)
    blksInHier=regexp(getfullname(sys),'\/','split');
    if(numel(blksInHier)>2)
        ret=get_param([blksInHier{1},'/',blksInHier{2}],'Handle');
    else
        ret=get_param(sys,'Handle');
    end
end