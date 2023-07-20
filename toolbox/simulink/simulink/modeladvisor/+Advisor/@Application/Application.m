classdef(CaseInsensitiveProperties=true)Application<matlab.mixin.Heterogeneous&matlab.mixin.Copyable








    events(Hidden)
IdChanged
WarningOccurred
Destroy
CheckExecutionStart



    end




    properties(Hidden)
        ShowWarnings=true;


        AnalyzeLibraries=false;
        ValueSetMap=[];
        ActiveValueSetID='_unnamed_';
    end

    properties(SetAccess=private)

        ID='';






        UseTempDir=false;




        AnalysisRoot='empty';
    end

    properties
        AnalyzeVariants=false;
    end

    properties(Hidden,SetAccess=private)

        AnalysisRootComponentId='';

        ComponentManager;
        TaskManager;
        VariantManager;
        VariantData={};


        AdvisorId='_modeladvisor_';


        BackgroundMode=false;
        ParallelMode=false;

        MultiMode=true;
        LegacyMode=false;






        IsParallelWorker=false;

        TempDir='';
        WorkingDir='';
        OriginalDir='';
    end

    properties(Access=private)
        MAObjs={};
        CompId2MAObjIdxMap;
        RootMAObj=[];

        AnalysisRootType=Advisor.component.Types.empty();
        RootModel='';


        listener=[];



        AsynchronousComponentSelectionCache={};


        CompileService;
        CompileErrors={};


        RunTime=0;


        Token='';

        CheckIDsExecuted={};
    end

    properties(Dependent,Access=private)
        SynchronizedExecution;
    end





    methods

        function isSynchronized=get.SynchronizedExecution(this)
            isSynchronized=~(this.BackgroundMode||this.ParallelMode);
        end


        function set.ID(this,id)
            data=Advisor.internal.ApplicationEventData(this.ID);
            this.ID=id;
            this.notify('IdChanged',data);
        end

        function set.AnalyzeVariants(this,val)
            if val


                [isInstalled,err]=slvariants.internal.utils.getVMgrInstallInfo('Model Advisor with variant configurations');
                if~isInstalled
                    throwAsCaller(err);
                end
            end
            this.AnalyzeVariants=val;
        end

    end





    methods









































        function ids=getCheckInstanceIDs(this,varargin)
            ids={};


            if strcmp(this.AnalysisRoot,'empty')
                DAStudio.error('Advisor:base:App_NotInitialized');
            end


            if~this.TaskManager.IsInitialized
                this.TaskManager.initialize(this.AnalysisRootComponentId);
            end

            if isempty(this.RootMAObj)

                [~,status]=this.updateModelAdvisorObj(this.AnalysisRootComponentId,true);

                if status==1

                    return;
                end
            end

            if~isempty(varargin)
                [varargin{:}]=convertStringsToChars(varargin{:});
                if ischar(varargin{1})
                    checkIDs=varargin(1);
                else
                    checkIDs=varargin{1};
                end
                ids=this.TaskManager.getTaskIDs(checkIDs);
            else
                ids=this.TaskManager.getTaskIDs();
            end
        end


        delete(this)
    end




    methods(Hidden=true)

        analyzeComponents(this);


        instIDs=resolveGroupIDs(this,names);


        [status,systemSIDs]=getStatusForTask(this,taskID);


        checkID=getCheckIDForInstance(this,checkInstanceID);


        names=getCheckInstanceNames(this,checkInstanceIDs);

        function selectCheckInstancesForDashboard(this,varargin)
            this.selectCheckInstances(varargin{:});

            mp=ModelAdvisor.Preferences;
            if~mp.MetricsDashboardRunExtensiveChecks

                ma=this.getRootMAObj;
                selectedChecks=this.getSelectedCheckInstances;
                flag=false(1,numel(selectedChecks));
                for i=1:numel(selectedChecks)
                    chk=selectedChecks{i};
                    flag(i)=any(strcmp(ma.getTaskObj(chk).Check.CallbackContext,{'SLDV','CGIR'}));
                end
                if any(flag)
                    this.deselectCheckInstances('IDs',selectedChecks(flag));
                end
            end
        end












        function this=Application(advisorId,useTempDir,token)

            advisorId=convertStringsToChars(advisorId);
            token=convertStringsToChars(token);



            this.checkLicense(token);
            this.Token=token;


            this.ID=Advisor.Application.getID(advisorId,...
            this.AnalysisRoot);

            this.AdvisorId=advisorId;

            this.CompId2MAObjIdxMap=containers.Map('KeyType','char','ValueType','any');


            this.UseTempDir=useTempDir;


            tempDir=tempname;
            mkdir(tempDir);
            this.TempDir=tempDir;



            this.TaskManager=Advisor.TaskManager(advisorId,this);

            this.ValueSetMap=containers.Map;
        end




        function maObj=getRootMAObj(this)
            if isa(this.RootMAObj,'Simulink.ModelAdvisor')
                maObj=this.RootMAObj;
            else
                maObj=[];
                this.RootMAObj=[];
            end
        end








        function maObjs=getMAObjs(this,varargin)
            maObjs={};

            if isempty(varargin)

                maObjs=this.MAObjs;
            else


                if length(varargin)==1
                    if iscell(varargin{1})
                        compIds=varargin{1};
                    else
                        compIds=varargin(1);
                    end

                    for n=1:length(compIds)
                        compId=compIds{n};

                        if this.CompId2MAObjIdxMap.isKey(compId)
                            idx=this.CompId2MAObjIdxMap(compId);
                            maObjs(end+1)=this.MAObjs(idx);%#ok<AGROW>
                        end
                    end
                else


                    systemName=varargin{2};
                    bdName=bdroot(systemName);

                    if strcmp(bdName,systemName)
                        compID=bdName;
                    else
                        compID=Advisor.component.ComponentIDGenerator.generateID(...
                        'SID',Simulink.ID.getSID(systemName));
                    end

                    if this.CompId2MAObjIdxMap.isKey(compID)
                        idx=this.CompId2MAObjIdxMap(compID);
                        maObj=this.MAObjs{idx};

                        if strcmp(maObj.SystemName,systemName)
                            maObjs{1}=maObj;
                        end
                    end
                end
            end
        end


        function maobj=findMAObjs(obj,SID)
            maobj={};
            for i=1:length(obj.MAObjs)
                if~isempty(obj.MAObjs{i})&&strcmp(bdroot(obj.MAObjs{i}.SystemName),SID)
                    maobj{end+1}=obj.MAObjs{i};%#ok<AGROW>
                end
            end
        end


        function handleRootCloseEvent(this,~,~)


            this.delete();
        end


        function ids=getChecksScheduledForExecution(this)
            if this.LegacyMode

                maObj=this.getRootMAObj();

                if strcmp(maObj.stage,'ExecuteCheckCallback')&&...
                    isfield(maObj.AtticData,'CheckIDsSelectedForExecution')

                    ids=maObj.AtticData.CheckIDsSelectedForExecution;

                else

                    ids={};
                end

            else




                ids=this.CheckIDsExecuted;
            end
        end


        function cs=getCompileService(this)
            cs=this.CompileService;
        end



        function[output,systemSIDs]=getOffendingObjects(this,taskObjID)
            output={};
            systemSIDs={};
            maObjs=this.getMAObjs();
            if~isempty(maObjs)
                taskObj=maObjs{1}.getTaskObj(taskObjID);
                if isempty(taskObj)
                    return
                else
                    taskIndex=taskObj.Index;
                end
                for i=1:length(maObjs)
                    checkobj=maObjs{i}.TaskAdvisorCellArray{taskIndex}.Check;
                    resultData={};

                    if strcmp(checkobj.CallbackStyle,'DetailStyle')
                        resultData=checkobj.ResultDetails;
                    else
                        resultData=checkobj.ProjectResultData;
                    end

                    if~iscell(resultData)
                        resultData=num2cell(resultData);
                    end

                    data={};
                    for j=1:numel(resultData)

                        if strcmp(checkobj.CallbackStyle,'DetailStyle')
                            if Simulink.ID.isValid(resultData{j}.Data)
                                data{end+1}=resultData{j}.Data;%#ok<AGROW>
                            end

                        elseif Simulink.ID.isValid(resultData{j})
                            data{end+1}=resultData{j};%#ok<AGROW>
                        end
                    end

                    output{end+1}=data;%#ok<AGROW>
                    systemSIDs{end+1}=Simulink.ID.getSID(maObjs{i}.SystemName);%#ok<AGROW>
                end
            end
        end



        checkInstanceIDs=getSelectedCheckInstances(this,varargin);



        function modes=getRequiredCompileModes(this,selectedTasks)
            modes=this.TaskManager.getRequiredCompileModes(selectedTasks);
        end

        setupExternalRun(this,selectedTaskIDs,varargin);





        function runForCompileMode(this,compileMode,systemSID)
            selectedTasks=this.TaskManager.getSelectedTasks('compileMode',compileMode);

            if~isempty(selectedTasks)
                taskObjIndexCellArray=this.TaskManager.taskIDs2Indices(selectedTasks);
                maObj=this.getMAObjs(systemSID);
                maObj{1}.runTasksForMode(compileMode,taskObjIndexCellArray,{});
            end
        end




        function handleExternalRunCompileFailure(this,err)
            cm=this.ComponentManager;


            props.Selected=true;



            selectedCompIds=cm.getComponentsWithProperties([],props);


            errstruct.Error=err;
            errstruct.Mode=Advisor.CompileModes.CommandLineSimulation;
            this.TaskManager.setCompileError({errstruct},this.RunTime,...
            selectedCompIds);
        end

        function CheckExecutionListener(this,eventSrc,eventData)%#ok<INUSL>
            notify(this,'CheckExecutionStart',Advisor.CheckExecutionStartEventDataClass(eventData.CheckID,eventData.CheckTitle,eventData.SystemName));
        end

        function setWorkingDir(this,directoryName)
            if~exist(directoryName,'dir')
                mkdir(directoryName);
            end
            this.WorkingDir=directoryName;
        end

        function createNewValueSet(obj)

            cm=obj.ComponentManager;
            if isempty(cm)||~cm.IsInitialized||cm.IsDirty
                obj.analyzeComponents();
            end

            obj.MAObjs={};
            obj.CompId2MAObjIdxMap=containers.Map;

            [selectedCompIds,~]=obj.getSelectedComponentsToExecute();
            for n=1:length(selectedCompIds)
                if strcmp(obj.AnalysisRootComponentId,selectedCompIds{n})
                    isRootModel=true;
                else
                    isRootModel=false;
                end
                obj.updateModelAdvisorObj(selectedCompIds{n},isRootModel);
            end

            obj.deselectCheckInstances;
            obj.selectCheckInstances('IDs',obj.VariantManager.backupSelectedCheckInstances);
        end

        function swapValueSet(obj,ID)
            if~strcmp(ID,obj.ActiveValueSetID)
                obj.ActiveValueSetID=ID;
                if obj.ValueSetMap.isKey(ID)
                    storedValueSet=obj.ValueSetMap(ID);
                    obj.MAObjs=storedValueSet.MAObjs;
                    obj.CompId2MAObjIdxMap=storedValueSet.CompId2MAObjIdxMap;
                    obj.RootMAObj=storedValueSet.RootMAObj;
                    Simulink.ModelAdvisor.getActiveModelAdvisorObj(obj.RootMAObj);
                else
                    obj.createNewValueSet;
                end
            end
        end

        function saveActiveValueSet(obj)
            CurrentValueSet.MAObjs=obj.MAObjs;
            CurrentValueSet.CompId2MAObjIdxMap=obj.CompId2MAObjIdxMap;
            CurrentValueSet.RootMAObj=obj.RootMAObj;
            obj.ValueSetMap(obj.ActiveValueSetID)=CurrentValueSet;
        end

        function setVariantData(obj,variantData)

            obj.VariantData=variantData;
        end


        function folderName=getVariantFolderName(obj)
            if strcmp(obj.ActiveValueSetID,'_unnamed_')
                folderName='';
            else
                folderName=obj.ActiveValueSetID;
            end
        end
    end




    methods(Access=private)

        applyComponentSelection(this,inputs)


        [maObj,status]=updateModelAdvisorObj(this,compId,isRootModel)


        runSynchronous(this)


        [selectedCompIds,subTrees]=setupRun(this)


        runNormalTasks(this,selectedCompIds,subTrees)


        runProcedureTasks(this,selectedCompIds,subTrees)


        runNonCompileTasks(this,selectedCompIds)


        runCompileTasks(this,modes,subTrees)


        createCompileService(this,models,rootmodels,modes)


        aggregateResults(this,varargin)



        [selectedCompIds,subTrees]=...
        getSelectedComponentsToExecute(this)

        initComponentManager(this);

        function initVariantManager(this,ApplicationID,AnalysisRoot)
            this.VariantManager=Advisor.variant.VariantManager();
            this.VariantManager.AnalysisRoot=AnalysisRoot;
            this.VariantManager.ApplicationID=ApplicationID;
        end


        deleteMAObjs(this)



        function deleteMAObj(this,compID)
            if this.CompId2MAObjIdxMap.iskey(compID)
                idxToDel=this.CompId2MAObjIdxMap(compID);
                maToDel=this.MAObjs{idx};

                if isa(maToDel,'Simulink.ModelAdvisor')




                    idxSlash=regexp(maToDel.SystemName,'/','once');
                    if isempty(idxSlash)
                        bdname=maToDel.SystemName;
                    else
                        bdname=maToDel.SystemName(1:idxSlash-1);
                    end

                    if bdIsLoaded(bdname)
                        bdObj=get_param(bdname,'object');

                        if bdObj.hasCallback('PostNameChange',this.ID)
                            Simulink.removeBlockDiagramCallback(...
                            bdroot(maToDel.SystemName),...
                            'PostNameChange',this.ID);
                        end
                    end

                    maToDel.deleteObj();
                end


                this.MAObjs(idxToDel)=[];
                this.CompId2MAObjIdxMap.remove(compID);



                this.CompId2MAObjIdxMap=containers.Map('KeyType','char','ValueType','any');

                n=1;
                while n<=length(this.MAObjs)
                    maObj=this.MAObjs{n};

                    if isa(maObj,'Simulink.ModelAdvisor')
                        this.CompId2MAObjIdxMap(maObj.ComponentId)=n;
                        n=n+1;
                    else

                        this.MAObjs(n)=[];
                    end
                end
            end
        end


        compileCallbackFct(this,src,evt)



        modelNameChangeCallbackFct(this,oldSystemName)



        function compileFailedCallbackFct(this,src,~)

            this.CompileErrors{end+1}.Error=src.getError();


            this.CompileErrors{end}.Mode=src.ActiveCompileMode;
        end

    end




    methods(Static=true)

    end




    methods(Static=true,Hidden)





        function ID=getID(CustomTARootID,analysisRoot)


            if isempty(analysisRoot)
                analysisRoot='empty';
            end

            ID=[CustomTARootID,'|',analysisRoot];


            sha256=matlab.internal.crypto.SecureDigester('SHA224');

            hexId=dec2hex(typecast(...
            sha256.computeDigest(uint8(ID)),'uint8'));

            ID=reshape(hexId,1,[]);



            ID=['A',ID];
        end









        function warning(msgId,varargin)
            app=Advisor.Manager.getActiveApplicationObj();

            if~isempty(app)

                if~isempty(varargin)
                    w=Advisor.internal.Warning(DAStudio.message(msgId,varargin{:}));

                    if app.ShowWarnings
                        MSLDiagnostic(msgId,varargin{:}).reportAsWarning;
                    end
                else
                    w=Advisor.internal.Warning(DAStudio.message(msgId));

                    if app.ShowWarnings
                        MSLDiagnostic(msgId).reportAsWarning;
                    end
                end


                notify(app,'WarningOccurred',w);
            end
        end
    end





    methods(Static,Access=private)



        function checkLicense(token)

            internalToken='MWAdvi3orAPICa11';

            if strcmp(token,internalToken)

            else

                if(Advisor.Utils.license('test','SL_Verification_Validation')==1)
                    Advisor.Utils.license('checkout','SL_Verification_Validation');
                else
                    DAStudio.error('Advisor:base:App_APIMissingLicense');
                end
            end
        end
    end
end
