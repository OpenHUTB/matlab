function open(harnessOwner,harnessName,varargin)



    try



        [systemModel,~]=Simulink.harness.internal.parseForSystemModel(harnessOwner);
    catch ME
        ME.throwAsCaller;
    end


    try
        [systemModel,harnessStruct]=Simulink.harness.internal.findHarnessStruct(harnessOwner,harnessName);

        if~(harnessStruct.canBeOpened)



            if(harnessStruct.isOpen==true)


                if strcmpi(get_param(harnessStruct.name,'Open'),'on')||...
                    any(strcmp(get_param(find_system(harnessStruct.name,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem'),'Open'),'on'))
                    open_system(harnessStruct.name);
                    return;
                end
            else

                activeHarness=Simulink.harness.internal.getHarnessList(systemModel,'active');
                if~isempty(activeHarness)
                    DAStudio.error('Simulink:Harness:AnotherHarnessAlreadyActivated',...
                    harnessName,activeHarness.name,activeHarness.model);
                end
            end
        else
            activeHarness=Simulink.harness.internal.getHarnessList(systemModel,'active');


            if~isempty(activeHarness)
                activeHarnessOwner=activeHarness.ownerFullPath;
                activeHarnessCUT=Simulink.harness.internal.getActiveHarnessCUT(systemModel);
                activeHarnessOwnerChecksum=Simulink.harness.internal.getBlockChecksum(get_param(activeHarnessOwner,'handle'));
                activeHarnessCUTChecksum=Simulink.harness.internal.getBlockChecksum(get_param(activeHarnessCUT,'handle'));
                res=isequal(activeHarnessOwnerChecksum,activeHarnessCUTChecksum);
                useMultipleHarnessOpen=slfeature('MultipleHarnessOpen');
                if useMultipleHarnessOpen&&~res&&~strcmp(get_param(activeHarnessCUT,'BlockType'),'ModelReference')



                    DAStudio.error('Simulink:Harness:ActiveHarnessWithUnSyncChangesFound',...
                    harnessName,activeHarness.name,activeHarness.model);
                elseif(useMultipleHarnessOpen&&isequal(activeHarness.synchronizationMode,0))



                    Simulink.harness.set(activeHarnessOwner,activeHarness.name,'SynchronizationMode','SyncOnOpen');

                end
                if useMultipleHarnessOpen&&isequal(harnessStruct.synchronizationMode,0)
                    Simulink.harness.set(harnessStruct.ownerFullPath,harnessStruct.name,'SynchronizationMode','SyncOnOpen');
                end
            end
        end


        p=inputParser;
        p.CaseSensitive=0;
        p.KeepUnmatched=0;
        p.PartialMatching=0;
        p.addParameter('SuppressRebuild',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));
        p.addParameter('ReuseWindow',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));
        p.addParameter('CreateOpenContext',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));
        p.parse(varargin{:});


        Simulink.harness.internal.sfcheck(harnessStruct.ownerHandle);



        sysH=get_param(systemModel,'handle');
        mainBDOpen=false;
        studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        for i=1:length(studios)
            if isequal(studios(i).App.blockDiagramHandle,sysH)

                mainBDOpen=true;
                break;
            end
        end




        if mainBDOpen
            createOpenContext=p.Results.CreateOpenContext;
            reuseWindow=p.Results.ReuseWindow;
        else


            createOpenContext=false;
            reuseWindow=false;
        end

        openContextScopeManager=GLUE2.OpenContextScopeManager();
        if createOpenContext
            if reuseWindow
                studioApp=SLM3I.SLDomain.getLastActiveStudioApp();
                openContextScopeManager.createContext(studioApp,'REUSE_STUDIO_SAVE_STATE');
            else


                DAStudio.error('Simulink:Harness:CreateOpenContextWithoutReuseWindowFlag');
            end
        end


        if strcmp(harnessStruct.ownerType,'Simulink.BlockDiagram')
            Simulink.harness.internal.openBDHarness(systemModel,harnessStruct.name,reuseWindow);
        else
            Simulink.harness.internal.openHarness(systemModel,harnessStruct.name,harnessStruct.ownerHandle,reuseWindow);
        end


        for dlg=DAStudio.ToolRoot.getOpenDialogs()'
            if strcmp(dlg.dialogTag,'CreateSimulationHarnessDialog')
                src=dlg.getSource();
                if strcmp(bdroot(src.harnessOwner.getFullName()),systemModel)
                    delete(dlg);
                end
            end
        end



        Simulink.harness.internal.refreshHarnessToolstrip(systemModel);


        if harnessStruct.rebuildOnOpen&&~p.Results.SuppressRebuild
            Simulink.harness.internal.rebuildAndNotify(harnessStruct);
        end




        Simulink.harness.internal.notifyLimitedSyncOnMultipleHarnessOpen(systemModel);


    catch ME

        Simulink.harness.internal.error(ME,true,...
        'Simulink:Harness:OpenHarnessStage',systemModel);
        throwAsCaller(ME);
    end
end
