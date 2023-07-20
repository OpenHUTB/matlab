

classdef Upgrader<handle&matlab.mixin.CustomDisplay
    properties
        ChecksToSkip={};
        SkipLibraries=false;
        SkipBlocksets=true;
        OneLevelOnly=false;
        ShowReport=true;
        VerboseLogging=false;
    end

    properties(SetAccess=protected)
        RootModel='';
        ReportFile='';
    end

    properties(Access=private)
        AnalysisMode=false;
        CancelRequest=false;
        TurnOnBackup=true;
        Logger=[];
        ShowProgressBar=false;
        CurrentModel;
        HierarchyCheckID='com.mathworks.Simulink.UpgradeAdvisor.UpgradeModelHierarchy';
        HierarchyTaskID='com.mathworks.Simulink.UpgradeAdvisor.UpgradeAdvisor';
        HierarchyTaskChildID='com.mathworks.Simulink.UpgradeAdvisor.UpgradeModelHierarchy.task';
        MdlAdvNodeObj;
        MdlAdvObj;
        NonHierarchyChecks;
        AutoSaveOptionsRestorer;
        ShowUI=false;
    end

    methods
        function obj=Upgrader(system)
            model=UpgradeAdvisor.load(system);
            obj.RootModel=model;
        end

        function analyze(obj)

            doUpgradeOrAnalysis(obj,true);
        end

        function upgrade(obj)

            doUpgradeOrAnalysis(obj,false);
        end

        function set.SkipBlocksets(obj,value)
            validateattributes(value,{'logical'},{'nonempty'});
            obj.SkipBlocksets=value;
        end

        function set.SkipLibraries(obj,value)
            validateattributes(value,{'logical'},{'nonempty'});
            obj.SkipLibraries=value;
        end

        function set.OneLevelOnly(obj,value)
            validateattributes(value,{'logical'},{'nonempty'});
            obj.OneLevelOnly=value;
        end

        function set.ShowReport(obj,value)
            validateattributes(value,{'logical'},{'nonempty'});
            obj.ShowReport=value;
        end

        function set.ChecksToSkip(obj,value)
            validateattributes(value,{'cell'},{});
            cellfun(...
            @(x)validateattributes(x,{'char','string'},{'nonempty'}),...
            value,'UniformOutput',false);
            obj.ChecksToSkip=value;
        end
    end

    methods(Access=protected)
        function footer=getFooter(obj)
            if~isscalar(obj)
                footer=getFooter@matlab.mixin.CustomDisplay(obj);
            else
                footer=sprintf('%s\n',...
                DAStudio.message('SimulinkUpgradeAdvisor:automation:WhatNext'));
            end
        end
    end

    methods(Hidden)
        function oldValue=setShowUI(obj,value)
            oldValue=obj.ShowUI;
            obj.ShowUI=value;
        end

        function logger=getLogger(obj)
            logger=obj.Logger;
        end

        function setLogger(obj,logger)
            obj.Logger=logger;
        end

        function children=getAllChecks(obj)



            mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(obj.CurrentModel);
            root=mdlAdvObj.TaskAdvisorRoot;
            children=root.getAllChildren;
        end

        function allCheckIDs=getAllCheckIDs(obj)
            children=obj.getAllChecks;
            allCheckIDs=cellfun(@(x)x.MAC,children,'UniformOutput',false);
        end

    end

    methods(Access=private)
        function turnOnAutoSave(obj)
            if~obj.TurnOnBackup
                return
            end
            autoSaveOptions=get_param(0,'AutoSaveOptions');
            current=autoSaveOptions.SaveBackupOnVersionUpgrade;
            obj.AutoSaveOptionsRestorer=...
            onCleanup(@()UpgradeAdvisor.Upgrader.setAutoSave(current));
            UpgradeAdvisor.Upgrader.setAutoSave(true);
        end

        function doUpgradeOrAnalysis(obj,analyzeOnly)
            if numel(obj)~=1
                DAStudio.error('SimulinkUpgradeAdvisor:automation:ExpectedScalar')
            end
            obj.AnalysisMode=analyzeOnly;
            try
                w2=warning('off','Simulink:Engine:LineWithoutSrc');
                w3=warning('off','Simulink:Engine:LineWithoutDst');
                w4=warning('off','Simulink:Engine:UnconnLine');
                w5=warning('off','Simulink:Harness:RedirectSaveHarnessToSystemModel');
                c5=onCleanup(@()warning(w5));
                c4=onCleanup(@()warning(w4));
                c3=onCleanup(@()warning(w3));
                c2=onCleanup(@()warning(w2));
                obj.runToCompletion;
                obj.finish;
            catch E
                E.throwAsCaller;
            end
        end

        function restoreAutoSaveSettings(obj)
            delete(obj.AutoSaveOptionsRestorer);
        end

        function isLibrary=isRootALibrary(obj)

            if bdIsLoaded(obj.RootModel)
                isLibrary=bdIsLibrary(obj.RootModel);
            else
                info=Simulink.MDLInfo(obj.RootModel);
                isLibrary=info.IsLibrary;
            end
        end

        function initialize(obj)
            if isempty(obj.Logger)

                obj.Logger=UpgradeAdvisor.internal.HTMLLogger;
            else

                obj.Logger.initialize;
            end
            obj.Logger.Echo=obj.VerboseLogging;
            obj.setCurrentModel(obj.RootModel,false);

            looper=UpgradeAdvisor.UpgradeLooper;
            if~isempty(looper.getCurrentModelName)
                looper.clearCurrentSession;
            end
            obj.turnOnAutoSave;
            UpgradeAdvisor.open(obj.CurrentModel,'noncompile',~obj.ShowUI);
            tf=dependencies.internal.analysis.toolbox.ToolboxFinder;
            tf.validate;
        end

        function finish(obj)
            obj.restoreAutoSaveSettings;
            obj.Logger.close;
            obj.Logger.generateReport;
            obj.ReportFile=obj.Logger.FileName;
            if obj.ShowReport
                obj.Logger.showReport;
            end
        end

        function setCurrentModel(obj,newCurrentModel,nextIsCompile)
            obj.CurrentModel=newCurrentModel;
            obj.Logger.setCurrentModel(newCurrentModel);
            try
                info=Simulink.MDLInfo(which(newCurrentModel));
                type=info.BlockDiagramType;
                if bdIsLoaded(newCurrentModel)
                    if strcmp(get_param(newCurrentModel,'IsHarness'),'on')
                        type='Test Harness';
                    end
                end
            catch E %#ok<NASGU>
                type='Block Diagram';
            end
            if nextIsCompile
                progressMessage=DAStudio.message(...
                'SimulinkUpgradeAdvisor:automation:AnalyzingModelCompileChecks',...
                type,newCurrentModel);
            else
                progressMessage=DAStudio.message(...
                'SimulinkUpgradeAdvisor:automation:AnalyzingModel',...
                type,newCurrentModel);
            end
            obj.Logger.addMessage(progressMessage);
            fprintf('%s\n',progressMessage);
        end

        function[inToolbox,toolboxName]=currentModelIsInToolbox(obj)
            toolboxName='';
            fp=which(obj.CurrentModel);

            tf=dependencies.internal.analysis.toolbox.ToolboxFinder;
            tbx=tf.fromPath(fp);
            inToolbox=~isempty(tbx);
            if inToolbox
                toolboxName=tbx.Name;
            end
        end

        function synchonizeChecksAndSkipList(obj)
            if isempty(obj.ChecksToSkip)
                return
            end
            checksToSkipAsChars=cellfun(@(x)char(x),obj.ChecksToSkip,'UniformOutput',false);
            children=obj.getAllChecks;
            allCheckIDs=cellfun(@(x)x.MAC,children,'UniformOutput',false);
            unknownChecks=setdiff(checksToSkipAsChars,allCheckIDs);
            if~isempty(unknownChecks)
                problemChecks='';
                joinStr=', ';
                for kk=1:numel(unknownChecks)
                    problemChecks=[problemChecks,unknownChecks{kk},joinStr];%#ok<AGROW>
                end
                problemChecks=problemChecks(1:end-length(joinStr));
                DAStudio.error(...
                'SimulinkUpgradeAdvisor:automation:UnknownChecksToSkip',...
                problemChecks)
            end

            for jj=1:numel(children)
                thisTask=children{jj};
                thisCheckID=thisTask.MAC;
                skipThisCheck=any(ismember(thisCheckID,checksToSkipAsChars));
                if skipThisCheck&&thisTask.Selected
                    thisTask.Selected=false;
                    if obj.ShowUI
                        thisTask.reset;
                    end
                    obj.Logger.addSkippedCheckMessage(DAStudio.message(...
                    'SimulinkUpgradeAdvisor:automation:SkippingCheck',...
                    thisTask.DisplayName));
                end
            end
        end


        function getMAObjects(obj)
            obj.MdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(obj.CurrentModel);
            obj.MdlAdvNodeObj=obj.MdlAdvObj.getTaskObj(obj.HierarchyTaskID);
        end


        function runAllEnabledChecks(obj)
            t0=clock;
            runTaskAdvisor(obj.MdlAdvNodeObj);
            checksTime=etime(clock,t0);
            obj.Logger.addTimingMessage(DAStudio.message(...
            'SimulinkUpgradeAdvisor:automation:TimeToRunChecks',...
            sprintf('%.1fs',checksTime)));
        end


        function sortCurrentChecks(obj)
            children=obj.MdlAdvNodeObj.Children;
            hierarchyCheckIndex=ismember(children,obj.HierarchyTaskChildID);
            obj.NonHierarchyChecks=children(~hierarchyCheckIndex);
        end


        function unlockLockedLibrary(obj)
            if bdIsLibrary(obj.CurrentModel)
                set_param(obj.CurrentModel,'Lock','off');
            end
        end


        function runAvailableFixes(obj)

            for jj=1:numel(obj.NonHierarchyChecks)
                if obj.CancelRequest
                    obj.Logger.addMessage(DAStudio.message(...
                    'SimulinkUpgradeAdvisor:automation:Cancelled'));
                    return
                end

                try

                    thisTaskID=obj.NonHierarchyChecks{jj};
                    taskObj=obj.MdlAdvObj.getTaskObj(thisTaskID);


                    if(taskObj.State~=ModelAdvisor.CheckStatus.NotRun)
                        checkObj=taskObj.Check;
                        checkID=checkObj.ID;
                        checkResult=obj.MdlAdvObj.getCheckResultStatus(checkID);


                        if checkResult
                            obj.Logger.addPassMessage(DAStudio.message(...
                            'SimulinkUpgradeAdvisor:automation:PassedCheckFor',...
                            taskObj.DisplayName));
                        else

                            if isa(checkObj.Action,'ModelAdvisor.Action')&&checkObj.Action.Enable
                                if obj.AnalysisMode
                                    obj.Logger.addFixAvailableMessage(DAStudio.message(...
                                    'SimulinkUpgradeAdvisor:automation:FixAvailableFor',...
                                    taskObj.DisplayName));
                                else
                                    try
                                        obj.unlockLockedLibrary;
                                        obj.MdlAdvObj.runAction(checkID,taskObj);
                                        obj.Logger.addFixedMessage(DAStudio.message(...
                                        'SimulinkUpgradeAdvisor:automation:AppliedFixFor',...
                                        taskObj.DisplayName));
                                    catch E
                                        disp(E)
                                        obj.Logger.addFailMessage(DAStudio.message(...
                                        'SimulinkUpgradeAdvisor:automation:FixFailedWithError',...
                                        E.message));
                                    end
                                end
                            else

                                obj.Logger.addUnfixedMessage(DAStudio.message(...
                                'SimulinkUpgradeAdvisor:automation:NoFixAvailableFor',...
                                taskObj.DisplayName));
                            end
                        end
                    end
                catch E
                    warning(E.message,'%s',E.identifier);
                end
            end
        end


        function runToCompletion(obj)
            obj.initialize;
            while true

                if obj.ShowUI
                    upgradeadvisor(obj.CurrentModel);
                    drawnow;
                end

                skipBecauseIsBlocksetFile=false;
                if obj.SkipBlocksets

                    [skipBecauseIsBlocksetFile,toolboxName]=currentModelIsInToolbox(obj);
                    if skipBecauseIsBlocksetFile
                        obj.Logger.addMessage(DAStudio.message(...
                        'SimulinkUpgradeAdvisor:automation:SkippingBlocksetFile',...
                        obj.CurrentModel,toolboxName));
                    end
                end

                if~(obj.SkipLibraries&&isRootALibrary(obj))&&~skipBecauseIsBlocksetFile

                    obj.synchonizeChecksAndSkipList;

                    obj.getMAObjects;

                    obj.MdlAdvObj.ShowProgressbar=obj.ShowProgressBar;

                    obj.runAllEnabledChecks;

                    obj.sortCurrentChecks;

                    obj.runAvailableFixes;
                end

                if~obj.AnalysisMode&&bdIsDirty(obj.CurrentModel)
                    obj.Logger.addMessage(DAStudio.message(...
                    'SimulinkUpgradeAdvisor:automation:SavedModelFile',...
                    obj.CurrentModel));
                    if obj.OneLevelOnly
                        save_system(obj.CurrentModel);
                    else
                        save_system(obj.CurrentModel,'SaveDirtyReferencedModels',true);
                    end
                end

                thisLoopingStatus=UpgradeAdvisor.internal.LoopingStatus(obj.CurrentModel);
                if~thisLoopingStatus.isLooping
                    break
                end

                if obj.OneLevelOnly
                    nextReference=openSameBlockDiagramAsCompileCheckSuppressUI(thisLoopingStatus);
                    if isempty(nextReference)
                        break
                    end
                else
                    if obj.SkipLibraries
                        nextReference=thisLoopingStatus.openNextModelNotLibraryinSequenceSuppressUI;
                        if isempty(nextReference)
                            break
                        end
                    else
                        nextReference=thisLoopingStatus.openNextModelinSequenceSuppressUI;
                    end
                end
                nextIsCompile=thisLoopingStatus.isNextACompileStep;
                obj.setCurrentModel(nextReference.name,nextIsCompile);
            end

        end

    end

    methods(Static,Hidden)
        function setAutoSave(value)
            autoSaveOptions=get_param(0,'AutoSaveOptions');
            autoSaveOptions.SaveBackupOnVersionUpgrade=value;
            set_param(0,'AutoSaveOptions',autoSaveOptions);
        end
    end
end
