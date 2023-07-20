function set(harnessOwner,harnessName,varargin)




    fieldsToUpdate={'Name','Description','RebuildOnOpen','RebuildModelData',...
    'RebuildWithoutCompile','SynchronizationMode','PostRebuildCallback',...
    'ExistingBuildFolder','FunctionInterfaceName'};

    try
        if nargin<4
            DAStudio.error('Simulink:Harness:NotEnoughInputArgsSet')
        end

        [systemModel,harnessStruct]=Simulink.harness.internal.findHarnessStruct(harnessOwner,harnessName);


        if bdIsLibrary(systemModel)&&strcmp('on',get_param(systemModel,'Lock'))&&~harnessStruct.isOpen
            DAStudio.error('Simulink:Harness:CannotSetHarnessWhenLibIsLocked',systemModel);
        end

        useMultipleHarnessOpen=0;
        try
            useMultipleHarnessOpen=slfeature('MultipleHarnessOpen');
        catch me
            if~(isequal(me.identifier,'sl_feature:utils:InvCallForFeatureName')||...
                isequal(me.identifier,'Simulink:Engine:InvCallForFeatureName'))
                rethrow(me);
            end
        end


        activeHarness=Simulink.harness.internal.getActiveHarness(systemModel);
        if useMultipleHarnessOpen==0
            if harnessStruct.canBeOpened==false&&~isempty(activeHarness)...
                &&(activeHarness.ownerHandle~=harnessStruct.ownerHandle||~strcmp(activeHarness.name,harnessStruct.name))
                DAStudio.error('Simulink:Harness:CannotUpdateWhenATestingHarnessIsActive',harnessStruct.name);
            end
        end

        existingBuildFolderParam=harnessStruct.existingBuildFolder;


        p=inputParser;
        p.CaseSensitive=0;
        p.KeepUnmatched=0;
        p.PartialMatching=0;

        synchronizationModes={'SyncOnOpenAndClose','SyncOnOpen','SyncOnPushRebuildOnly'};
        synchronizationMode=synchronizationModes{harnessStruct.synchronizationMode+1};

        p.addParameter(fieldsToUpdate{1},harnessStruct.name,@(x)validateattributes(x,{'char'},{'nonempty'}));
        p.addParameter(fieldsToUpdate{2},harnessStruct.description,@(x)validateattributes(x,{'char'},{'real'}));
        p.addParameter(fieldsToUpdate{3},harnessStruct.rebuildOnOpen,@(x)validateattributes(x,{'logical'},{'nonempty'}));
        p.addParameter(fieldsToUpdate{4},harnessStruct.rebuildModelData,@(x)validateattributes(x,{'logical'},{'nonempty'}));
        p.addParameter(fieldsToUpdate{5},harnessStruct.graphical,@(x)validateattributes(x,{'logical'},{'nonempty'}));
        p.addParameter(fieldsToUpdate{6},synchronizationMode,@(x)any(validatestring(x,synchronizationModes)));
        p.addParameter(fieldsToUpdate{7},harnessStruct.postRebuildCallback,@(x)validateattributes(x,{'char'},{'real'}));
        p.addParameter(fieldsToUpdate{8},existingBuildFolderParam,@(x)validateattributes(x,{'char'},{'real'}));
        p.addParameter(fieldsToUpdate{9},harnessStruct.functionInterfaceName,@(x)validateattributes(x,{'char'},{'real'}));

        p.parse(varargin{:});


        Simulink.harness.internal.ensureNoRepeatedParams(varargin);


        changeFields=setdiff(fieldsToUpdate,p.UsingDefaults);

        rebuildOnOpen=p.Results.RebuildOnOpen;
        rebuildModelData=p.Results.RebuildModelData;
        postRebuildCallback=p.Results.PostRebuildCallback;
        description=p.Results.Description;
        graphical=p.Results.RebuildWithoutCompile;
        synchronizationMode=p.Results.SynchronizationMode;
        existingBuildFolderArg=p.Results.ExistingBuildFolder;
        functionInterfaceName=p.Results.FunctionInterfaceName;

        if(harnessStruct.verificationMode==0&&...
            ~isempty(existingBuildFolderArg))
            DAStudio.error('Simulink:Harness:NormalHarnessBuildFolderWarning');
            existingBuildFolderArg='';
        end

        harnessName=harnessStruct.name;
        ownerUDD=get_param(harnessStruct.ownerHandle,'Object');
        for i=1:length(changeFields)
            switch changeFields{i}
            case 'SynchronizationMode'
                harnessList=Simulink.harness.internal.getHarnessList(systemModel,'loaded');
                isCurrHarnessAmongLoadedHarness=Simulink.harness.internal.isCurrentHarnessLoaded(harnessStruct.name,harnessList);
                if((useMultipleHarnessOpen==1)&&(length(harnessList)>1)&&isCurrHarnessAmongLoadedHarness)
                    DAStudio.error('Simulink:Harness:CannotChangeSyncModeWhenHarnessLoaded',harnessStruct.name);
                end

                if(useMultipleHarnessOpen==0)&&~isempty(activeHarness)&&~strcmpi(synchronizationMode,synchronizationModes{harnessStruct.synchronizationMode+1})

                    if strcmpi(synchronizationMode,synchronizationModes{3})||harnessStruct.synchronizationMode==2
                        DAStudio.error('Simulink:Harness:CannotUpdateSyncModeHarnessActive',harnessStruct.name);
                    end
                end


                if isa(ownerUDD,'Simulink.BlockDiagram')&&strcmpi(synchronizationMode,synchronizationModes{1})
                    Simulink.harness.internal.warn({'Simulink:Harness:InvalidSyncModeForBD'});
                    synchronizationMode=synchronizationModes{harnessStruct.synchronizationMode+1};
                end

                if bdIsLibrary(systemModel)&&strcmpi(synchronizationMode,synchronizationModes{3})
                    Simulink.harness.internal.warn({'Simulink:Harness:InvalidSyncModeForLibrary'});
                    synchronizationMode=synchronizationModes{harnessStruct.synchronizationMode+1};
                end


                if bdIsSubsystem(systemModel)&&~strcmpi(synchronizationMode,synchronizationModes{1})
                    Simulink.harness.internal.warn({'Simulink:Harness:InvalidSyncModeForLibrary'});
                    synchronizationMode=synchronizationModes{harnessStruct.synchronizationMode+1};
                end


                if~strcmpi(synchronizationMode,synchronizationModes{2})&&~isa(ownerUDD,'Simulink.BlockDiagram')&&...
                    Simulink.harness.internal.isImplicitLink(harnessStruct.ownerHandle)

                    Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForImplicitLink','SynchronizationMode','SyncOnOpen'});
                    synchronizationMode=synchronizationModes{2};
                end

                if harnessStruct.verificationMode~=0&&~strcmpi(synchronizationMode,synchronizationModes{3})
                    Simulink.harness.internal.warn('Simulink:Harness:InvalidSyncModeForSILPIL');
                    synchronizationMode=synchronizationModes{3};
                end

                if Simulink.internal.isArchitectureModel(systemModel)&&~strcmpi(synchronizationMode,synchronizationModes{2})

                    Simulink.harness.internal.warn('Simulink:Harness:InvalidSyncModeForZCHarness');
                    synchronizationMode=synchronizationModes{2};
                end
            case 'Name'
                newHarnessName=p.Results.Name;
                if~isequal(harnessName,newHarnessName)
                    Simulink.harness.internal.validateHarnessName(harnessStruct.model,harnessStruct.ownerFullPath,newHarnessName);
                end
                harnessName=newHarnessName;

            case{'RebuildOnOpen','RebuildModelData','RebuildWithoutCompile'}
                if(bdIsLibrary(systemModel)&&isempty(harnessStruct.functionInterfaceName))||bdIsSubsystem(systemModel)
                    if rebuildOnOpen
                        Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForLibHarness','RebuildOnOpen','false'});
                        rebuildOnOpen=false;
                    end

                    if rebuildModelData
                        Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForLibHarness','RebuildModelData','false'});
                        rebuildModelData=false;
                    end

                    if~graphical
                        Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForLibHarness','RebuildWithoutCompile','true'});
                        graphical=true;
                    end
                end
            case 'PostRebuildCallback'
                if bdIsLibrary(systemModel)||bdIsSubsystem(systemModel)
                    if postRebuildCallback~=""
                        Simulink.harness.internal.warn({'Simulink:Harness:InvalidPostRebuildCBForLibHarness'});
                        postRebuildCallback='';
                    end
                end
                Simulink.harness.internal.validatePostRebuildCB(postRebuildCallback);
            case 'FunctionInterfaceName'
                if~isempty(functionInterfaceName)
                    codeContext=Simulink.libcodegen.internal.getCodeContext(harnessStruct.model,harnessStruct.ownerHandle,functionInterfaceName);
                    if isempty(codeContext)
                        DAStudio.error('Simulink:CodeContext:CodeContextNotFound',functionInterfaceName,harnessStruct.ownerFullPath);
                    end

                    if~Simulink.harness.internal.isRLS(harnessStruct.ownerHandle)
                        DAStudio.error('Simulink:CodeContext:CodeContextInvalidOwnerTypeForHarness',harnessStruct.ownerFullPath);
                    end
                end
            otherwise

            end
        end

        if~harnessStruct.isOpen||~strcmp(harnessStruct.name,harnessName)
            Simulink.harness.internal.checkFilesWritable(systemModel,harnessStruct,'set',true);
        end



    catch ME
        ME.throwAsCaller();
    end

    try

        oldwarn=warning('OFF','Simulink:Engine:MdlFileShadowing');
        cleanupWarning=onCleanup(@()warning(oldwarn));

        synchronizationMode=find(strcmpi(synchronizationModes,synchronizationMode))-1;

        Simulink.harness.internal.updateHarness(harnessStruct.model,harnessStruct,harnessName,...
        description,rebuildOnOpen,rebuildModelData,postRebuildCallback,graphical,synchronizationMode,...
        existingBuildFolderArg,functionInterfaceName);
    catch ME
        Simulink.harness.internal.warn(ME);
    end


    Simulink.harness.internal.refreshHarnessListDlg(harnessStruct.model);

    if harnessStruct.isOpen

        mgr=Simulink.harness.internal.toolstrip.TestHarnessContextManager.getContext(get_param(harnessName,'handle'));
        mgr.refresh;
    end

end
