function initData(this,needLoadSlprj)




    am=Advisor.Manager.getInstance();


    cmdLineRun=this.CmdLine;


    this.AtticData.CharSetDef='<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>';
    WorkDir=this.AtticData.WorkDir;

    this.AtticData.DiagnoseRightFrame=[WorkDir,filesep,'report.html'];

    savedCopy=this.Database.loadLatestData('MdladvInfo');
    if~cmdLineRun&&this.ShowProgressbar&&~isempty(am.Progressbar)&&ishandle(am.Progressbar)
        waitbar(0.5,am.Progressbar,DAStudio.message('ModelAdvisor:engine:LoadingChecks'));
    end

    [checkCellArray,GroupedrecordTree,taskCellArray,callbackFuncInfoStruct]=am.copySlCustomizationData('Check');

    this.CheckCellArray=checkCellArray;

    this.CheckIDMap=containers.Map;
    for i=1:length(checkCellArray)
        this.CheckIDMap(checkCellArray{i}.ID)=checkCellArray{i}.Index;
    end

    this.TaskCellArray=taskCellArray;
    this.AtticData.GroupedrecordTree=GroupedrecordTree;
    this.AtticData.callbackFuncInfoStruct=callbackFuncInfoStruct;

    needCleanSlprjDir=false;

    MADatabase=[WorkDir,filesep,'ModelAdvisorData'];

    if~isempty(savedCopy)&&(exist(MADatabase,'file')||this.parallel)
        if isempty(savedCopy.callbackFuncInfoStruct)

            needLoadSlprj=false;
        else
            if~cmdLineRun&&this.ShowProgressbar&&~isempty(am.Progressbar)&&ishandle(am.Progressbar)
                waitbar(0.8,am.Progressbar,DAStudio.message('ModelAdvisor:engine:VerifyRptChecksum'));
            end

            needCleanSlprjDir=compare_with_savedinfo(checkCellArray,...
            taskCellArray,callbackFuncInfoStruct,savedCopy,this);


            if needCleanSlprjDir
                cleanup_slprj(this);

                needLoadSlprj=false;

                this.Database.keepConnectionAlive=false;
                if this.ContinueViewExistRpt
                    return
                end
            end
        end
    else

        needLoadSlprj=false;
    end

    if needLoadSlprj
        CacheDependantInputParam={};

        if~this.ContinueViewExistRpt

        end

        loc_initTaskAdvisor(this);
        if~this.ContinueViewExistRpt

            CacheDependantInputParam=loc_loadMASessionData(this,savedCopy,'Check');

            loc_loadMASessionData(this,savedCopy,'TaskAdvisor');
            this.hasLoadedExistingData=true;
        end
        for i=1:length(CacheDependantInputParam)
            this.CheckCellArray{CacheDependantInputParam{i}.CheckIndex}.InputParameters{CacheDependantInputParam{i}.InputParamIndex}=CacheDependantInputParam{i}.Value;
        end

        loc_loadMASessionData(this,savedCopy,'R2F');
        this.Database.keepConnectionAlive=false;
        return
    else

        loc_initTaskAdvisor(this);


        this.Database.cacheMAInitData;




        if needCleanSlprjDir


            this.Database.saveMASessionData;
        end
    end

    this.Database.keepConnectionAlive=false;
end


function loc_initTaskAdvisor(this)



    dbStackInfo=dbstack('-completenames');
    if~isempty(strfind(dbStackInfo(end).file,['@ModelAdvisor',filesep,'run.m']))
        cmdLineRun=true;
    else
        cmdLineRun=false;
    end


    this.TaskAdvisorRoot=ModelAdvisor.Group('SysRoot');
    this.TaskAdvisorRoot.DisplayName=DAStudio.message('Simulink:tools:MAModelAdvisor');
    this.TaskAdvisorRoot.ShowCheckbox=false;

    this.TaskAdvisorRoot.MAObj=this;

    am=Advisor.Manager.getInstance();

    [topLevelWorkFlows,this.TaskAdvisorCellArray]=am.copySlCustomizationData('GUI',this);










    PerfTools.Tracer.logMATLABData('MAGroup','Link Objects',true);



    customTARoot='';
    if~strcmp(this.CustomTARootID,'_modeladvisor_')

        for i=1:length(this.TaskAdvisorCellArray)
            if strcmp(this.TaskAdvisorCellArray{i}.ID,this.CustomTARootID)
                customTARoot=this.TaskAdvisorCellArray{i};
                break;
            end
        end
    end
    if~isempty(customTARoot)
        this.TaskAdvisorRoot=customTARoot;
        this.CustomObject=customTARoot.CustomObject;
    else
        this.TaskAdvisorRoot.ChildrenObj=[this.TaskAdvisorRoot.ChildrenObj,topLevelWorkFlows];
        for i=1:length(topLevelWorkFlows)
            this.TaskAdvisorRoot.Children{end+1}=topLevelWorkFlows{i}.ID;
            this.TaskAdvisorRoot.addChildren(topLevelWorkFlows{i},'connect_only');
            topLevelWorkFlows{i}.ParentObj=this.TaskAdvisorRoot;
            if isa(topLevelWorkFlows{i},'ModelAdvisor.Group')
                modeladvisorprivate('modeladvisorutil2','CalculateTreeInitStatus',topLevelWorkFlows{i});
            end
        end
    end

    for i=1:length(this.TaskAdvisorCellArray)


        if isa(this.TaskAdvisorCellArray{i},'ModelAdvisor.Procedure')&&(isa(this.TaskAdvisorCellArray{i}.getParent,'ModelAdvisor.Group')&&~isa(this.TaskAdvisorCellArray{i}.getParent,'ModelAdvisor.Procedure'))...
            &&~isempty(this.TaskAdvisorCellArray{i}.getParent.getParent)
            this.TaskAdvisorCellArray{i}.ShowCheckbox=true;
        end
        this.TaskAdvisorCellArray{i}.MAObj=this;
    end






    this.generateAdvertisements();




    try
        loc_checkTreeStructure(this.TaskAdvisorRoot);
    catch E

        this.ErrorLog{end+1}=E.message;
        disp(E.message);
    end


    if~cmdLineRun&&desktop('-inuse')&&this.ShowWarnDialog&&~isempty(this.ErrorLog)
        warnmessage='';
        for i=1:length(this.ErrorLog)
            warnmessage=[warnmessage,this.ErrorLog{i},newline];%#ok<AGROW>
        end
        warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MAErrorMACallbackFunc',warnmessage));
        set(warndlgHandle,'Tag','MAErrorMACallbackFunc');
    end
    ModelAdvisor.setInstallConfiguration;


    PerfTools.Tracer.logMATLABData('MAGroup','Link Objects',false);
end


function cleanup_slprj(this)
    warnmsg=getString(message('ModelAdvisor:engine:WarnSlprjOutOfDate'));
    if~this.CmdLine&&desktop('-inuse')
        response=questdlg(warnmsg,getString(message('ModelAdvisor:engine:CmdAPIWarningDialogTitle')),...
        getString(message('ModelAdvisor:engine:ContViewExistRpt')),...
        getString(message('ModelAdvisor:engine:RmRptandCont')),...
        getString(message('ModelAdvisor:engine:RmRptandCont')));
    else
        response=getString(message('ModelAdvisor:engine:RmRptandCont'));
    end
    if isempty(response)

        this.ContinueViewExistRpt=true;
    elseif strcmp(response,getString(message('ModelAdvisor:engine:ContViewExistRpt')))

        pause(2);
        this.ContinueViewExistRpt=true;
        this.displayReport(this.AtticData.DiagnoseRightFrame);
    else
        if~this.CmdLine
            disp(DAStudio.message('Simulink:tools:MARemoveExistReport'));
        end

        if isa(this.Database,'ModelAdvisor.Repository')
            delete(this.Database);
        end

        rmdir(this.AtticData.WorkDir,'s');

        this.getWorkDir;
        this.Database=ModelAdvisor.Repository(this);
    end
end


function loc_checkTreeStructure(root)
    if isa(root,'ModelAdvisor.Group')
        if isa(root,'ModelAdvisor.Procedure')
            if length(root.Children)~=length(root.ChildrenObj)
                DAStudio.error('Simulink:tools:MAIncompleteTreeStructure',root.DisplayName);
            end
        end
        for i=1:length(root.ChildrenObj)
            loc_checkTreeStructure(root.ChildrenObj{i});
        end
    end
end


function indexArray=loc_getAllChindrenIndex(this)
    indexArray={};
    if isa(this,'ModelAdvisor.Group')
        if isempty(this.AllChildrenIndex)
            for i=1:length(this.ChildrenObj)
                indexArray{end+1}=this.ChildrenObj{i}.Index;%#ok<AGROW>
                if isa(this.ChildrenObj{i},'ModelAdvisor.Group')&&~isempty(this.ChildrenObj{i}.Children)
                    indexArray=[indexArray,loc_getAllChindrenIndex(this.ChildrenObj{i})];%#ok<AGROW>
                end
            end
            this.AllChildrenIndex=indexArray;
        else
            indexArray=this.AllChildrenIndex;
        end
    end
end


function CacheDependantInputParam=loc_loadMASessionData(maobj,savedCopy,phase)
    CacheDependantInputParam={};
    switch phase
    case 'Check'

        cacheCheckCellArray=maobj.CheckCellArray;
        for i=1:length(cacheCheckCellArray)

            DependantInputParam=loadCheckData(cacheCheckCellArray{i},savedCopy.recordCellArray{i},i);
            if~isempty(DependantInputParam)
                CacheDependantInputParam=[CacheDependantInputParam,DependantInputParam];%#ok<AGROW>
            end
        end

        clear cacheCheckCellArray;
        for i=1:length(maobj.TaskCellArray)
            maobj.TaskCellArray{i}.Selected=savedCopy.taskCellArray{i}.Selected;
        end
        maobj.StartInTaskPage=savedCopy.StartInTaskPage;
    case 'TaskAdvisor'
        if isfield(savedCopy,'TaskAdvisorCellArray')
            TaskAdvisorCellArray=maobj.TaskAdvisorCellArray;
            if length(savedCopy.TaskAdvisorCellArray)==length(TaskAdvisorCellArray)
                for i=1:length(TaskAdvisorCellArray)


                    TaskAdvisorCellArray{i}.State=savedCopy.TaskAdvisorCellArray{i}.State;
                    if ischar(TaskAdvisorCellArray{i}.State)
                        TaskAdvisorCellArray{i}.State=ModelAdvisor.CheckStatusUtil.getStatusFromString(TaskAdvisorCellArray{i}.State);
                    end
                    TaskAdvisorCellArray{i}.Selected=savedCopy.TaskAdvisorCellArray{i}.Selected;

                    TaskAdvisorCellArray{i}.InternalState=savedCopy.TaskAdvisorCellArray{i}.InternalState;
                    TaskAdvisorCellArray{i}.Failed=savedCopy.TaskAdvisorCellArray{i}.Failed;
                    TaskAdvisorCellArray{i}.Enable=savedCopy.TaskAdvisorCellArray{i}.Enable;
                    TaskAdvisorCellArray{i}.StateIcon=savedCopy.TaskAdvisorCellArray{i}.StateIcon;
                    TaskAdvisorCellArray{i}.RunTime=savedCopy.TaskAdvisorCellArray{i}.RunTime;

                    if isfield(savedCopy.TaskAdvisorCellArray{i},'InputParameters')
                        for k=1:length(savedCopy.TaskAdvisorCellArray{i}.InputParameters)
                            if k<=length(TaskAdvisorCellArray{i}.InputParameters)
                                if~strcmp(TaskAdvisorCellArray{i}.InputParameters{k}.Type,'PushButton')
                                    TaskAdvisorCellArray{i}.InputParameters{k}=savedCopy.TaskAdvisorCellArray{i}.InputParameters{k};
                                end
                            end
                        end
                    end
                    if isa(TaskAdvisorCellArray{i},'ModelAdvisor.Task')&&~isempty(savedCopy.TaskAdvisorCellArray{i}.Check)

                        loadCheckData(TaskAdvisorCellArray{i}.Check,savedCopy.TaskAdvisorCellArray{i}.Check,i);
                    end
                end
            end

            clear TaskAdvisorCellArray;

            modeladvisorprivate('modeladvisorutil2','CalculateTreeInitStatus',maobj.TaskAdvisorRoot);
        end
    case 'R2F'

        maobj.R2FMode=savedCopy.R2FInfo.R2FMode;
        maobj.R2FStart=maobj.getTaskObj(savedCopy.R2FInfo.R2FStart);
        maobj.R2FStop=maobj.getTaskObj(savedCopy.R2FInfo.R2FStop);

        if isfield(savedCopy,'MAExplorerPosition')
            maobj.MAExplorerPosition=savedCopy.MAExplorerPosition;
        end
    otherwise
        DAStudio.error('ModelAdvisor:engine:UnkownStageSpecified',phase);
    end
end

function CacheDependantInputParam=loadCheckData(checkObj,savedData,index)
    CacheDependantInputParam={};
    checkObj.Selected=savedData.Selected;
    checkObj.ResultInHTML=savedData.ResultInHTML;
    if isfield(savedData,'InputParameters')
        for k=1:length(savedData.InputParameters)
            if k>length(checkObj.InputParameters)
                CacheDependantInputParam{end+1}.CheckIndex=index;%#ok<AGROW>
                CacheDependantInputParam{end}.InputParamIndex=k;
                CacheDependantInputParam{end}.Value=savedData.InputParameters{k};
            else

                if~(isa(checkObj.InputParameters{k},'ModelAdvisor.InputParameter')&&strcmp(checkObj.InputParameters{k}.Type,'PushButton'))
                    checkObj.InputParameters{k}=savedData.InputParameters{k};
                end
            end
        end
    end
    if isa(checkObj,'ModelAdvisor.Check')
        checkObj.Enable=savedData.Enable;
        checkObj.Success=savedData.Success;
        checkObj.ErrorSeverity=savedData.ErrorSeverity;
        if isfield(savedData,'status')
            checkObj.setStatus(savedData.status);
        else
            if(savedData.Success||~isempty(savedData.ResultInHTML)||...
                ~(isempty(savedData.CacheResultInHTMLForNewCheckStyle)))
                setLegacyCheckStatus(checkObj);
            end
        end
        if~strcmp(savedData.ActionResultInHTML,'not exist')
            checkObj.Action.ResultInHTML=savedData.ActionResultInHTML;
        end
        checkObj.ProjectResultData=savedData.ProjectResultData;
        checkObj.setReportStyle(savedData.ReportStyle);
        checkObj.setCacheResultInHTMLForNewCheckStyle(savedData.CacheResultInHTMLForNewCheckStyle);

    end
end

function needCleanSlprjDir=compare_with_savedinfo(recordCellArray,taskCellArray,callbackFuncInfoStruct,savedCopy,this)
    needCleanSlprjDir=false;

    try


        if isfield(savedCopy.callbackFuncInfoStruct,'Hash')
            if~strcmp(savedCopy.callbackFuncInfoStruct.Hash,callbackFuncInfoStruct.Hash)
                needCleanSlprjDir=true;
            else

                ConfigFileName=modeladvisorprivate('modeladvisorutil2','GetConfigFileName',this);
                ConfigFilePathInfo=dir(ConfigFileName);
                if isempty(ConfigFilePathInfo)
                    ConfigFilePathInfo=[];
                    ConfigFilePathInfo.name='';
                    ConfigFilePathInfo.date='';
                else
                    ConfigFilePathInfo.name=ConfigFileName;
                end
                if~strcmp(ConfigFilePathInfo.name,savedCopy.ConfigFilePathInfo.name)||...
                    ~strcmp(ConfigFilePathInfo.date,savedCopy.ConfigFilePathInfo.date)
                    needCleanSlprjDir=true;
                end




                if this.CmdLine&&exist(savedCopy.ConfigFilePathInfo.name,'file')
                    [~,~,ext]=fileparts(savedCopy.ConfigFilePathInfo.name);
                    if strcmp(ext,'.json')
                        configData=jsondecode(fileread(savedCopy.ConfigFilePathInfo.name));
                        if~iscell(configData)
                            configData=num2cell(configData);
                        end
                        for i=2:length(configData)
                            if(configData{i}.check~=savedCopy.TaskAdvisorCellArray{i}.Selected)
                                needCleanSlprjDir=true;
                                break;
                            end
                        end
                    else
                        configData=load(savedCopy.ConfigFilePathInfo.name);
                        for i=1:length(configData.configuration.ConfigUICellArray)
                            if(configData.configuration.ConfigUICellArray{i}.Selected~=savedCopy.TaskAdvisorCellArray{i}.Selected)
                                needCleanSlprjDir=true;
                                break;
                            end
                        end
                    end
                end
            end
        else
            needCleanSlprjDir=true;
        end
    catch


        needCleanSlprjDir=true;
    end
end
