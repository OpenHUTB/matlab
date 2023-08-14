function[successful,result]=runBuildAdvisor(hSys,alwaysDisplay,toRun,varargin)




    fixedCheck=coder.advisor.internal.CGOFixedCheck;
    checkID=fixedCheck.checkID;
    doCustomization=true;

    if~isempty(varargin)
        mode=varargin{1};
    else
        mode='';
    end



    if ModelAdvisor.isRunning()
        mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        if mdladvObj.runInBackground
            DAStudio.warning('ModelAdvisor:engine:MABackgroundRunningWarning');
        end
        result=[];
        successful=true;
        return;
    end


    if exist('rtw.codegenObjectives.ObjectiveCustomizer','class')<=0
        doCustomization=false;
    end

    if doCustomization
        cm=DAStudio.CustomizationManager;
        addChkLen=length(cm.ObjectiveCustomizer.additionalCheck);
        for i=1:addChkLen
            checkID{end+1}=cm.ObjectiveCustomizer.additionalCheck{i};%#ok
        end

        am=Advisor.Manager.getInstance;
        am.updateCacheIfNeeded;
    end

    hMdl=bdroot(hSys);
    hConfigSet=getActiveConfigSet(hMdl);
    op=hConfigSet.get_param('ObjectivePriorities');
    opId=op;

    cm=DAStudio.CustomizationManager;
    if~cm.ObjectiveCustomizer.initialized
        cm.ObjectiveCustomizer.initialize();
    end

    objWODef=cell(length(op),1);
    objWODefIdx=0;
    for i=1:length(op)
        objName=cm.ObjectiveCustomizer.IDToNameHash.get(op{i});
        if isempty(objName)
            objWODefIdx=objWODefIdx+1;
            objWODef{objWODefIdx}=op{i};
        else
            op{i}=objName;
        end
    end

    if objWODefIdx>0
        objs=[];
        for j=1:objWODefIdx
            if j==1
                objs=['''',objWODef{j},''''];
            else
                objs=[objs,',','''',objWODef{j},''''];%#ok
            end
        end
        msgtext=DAStudio.message('RTW:configSet:customizedObjWithoutDefNoCodeGenAdvisorError',objs);
        msgbox(msgtext,'Error');

        DAStudio.error('RTW:configSet:customizedObjWithoutDefNoCodeGenAdvisorError',objs);
    end

    ertTargetCode=strcmpi(get_param(hConfigSet,'IsERTTarget'),'on');

    if~ertTargetCode&&(length(op)>1||...
        (length(op)==1&&~ismember(op{1},{'Debugging','Execution efficiency'})))
        op_old='';
        for i=1:length(op)
            if i==1
                op_old=[op{i}];
            else
                op_old=[op_old,' ',op{i}];%#ok
            end
        end
        op{1}=[];%#ok
        hConfigSet.set_param('ObjectivePriorities',{});

        backtrace_status=warning('query','backtrace');
        warning('off','backtrace');

        DAStudio.warning('Simulink:slbuild:advisorWarning2',op_old);

        if isequal(backtrace_status.state,'on')
            warning('on','backtrace');
        end
    end

    ret=true;
    rtwgenMode=strcmp(mode,'rtwgen');

    cgoGroupId='com.mathworks.cgo.group';

    mdlObj=get_param(bdroot(hMdl),'Object');
    mdladvObj=mdlObj.getModelAdvisorObj;


    originalID=mdladvObj.CustomTARootID;
    mdladvObj.CustomTARootID=cgoGroupId;
    try
        workDir=mdladvObj.getWorkDir('CheckOnly');
        if exist(workDir,'dir')&&~rtwgenMode
            [~,~,~]=rmdir(workDir,'s');
        end
    catch
    end
    mdladvObj.CustomTARootID=originalID;

    if~rtwgenMode

        mdladv=Simulink.ModelAdvisor.getModelAdvisor(hSys,'new',cgoGroupId);
    else

        mdladv=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    end
    mdladv.getWorkDir;

    if doCustomization
        objCustmizr=cm.ObjectiveCustomizer;
        if~isempty(objCustmizr.objective)
            recordCellArray=mdladv.CheckCellArray;
            realCheckIDMap=containers.Map(...
            cellfun(@(x)x.ID,recordCellArray,'UniformOutput',false),...
            ones(size(recordCellArray)));

            for i=1:length(objCustmizr.objective)
                for k=1:length(objCustmizr.objective{i}.checks)
                    if~realCheckIDMap.isKey(objCustmizr.objective{i}.checks{k}.MAC)
                        successful=false;
                        result=[];
                        args{1}='badCheckIDError';
                        args{2}=cm.ObjectiveCustomizer.IDToNameHash.get(objCustmizr.objective{i}.objectiveID);
                        args{3}=objCustmizr.objective{i}.checks{k}.MAC;
                        args{4}=objCustmizr.objective{i}.customizationFileLocation;
                        rtw.codegenObjectives.ObjectiveCustomizer.WarningMsg(args);
                        uiwait(warndlg(DAStudio.message('Simulink:tools:badCheckIDError',...
                        args{2},args{3},args{4}),...
                        DAStudio.message('Simulink:tools:badCheckIDErrorMsgBoxTitle'),'modal'));
                        return;
                    end
                end
            end
        end
    end

    if ismethod(mdladv,'generateAdvertisements')
        mdladv.generateAdvertisements();
    end

    if~isa(mdladv,'Simulink.ModelAdvisor')
        disp('Failed to obtain model advisor');
        successful=ret;
        result=[];
        return;
    end

    if isa(mdladv.MAExplorer,'DAStudio.Explorer')
        mdladv.MAExplorer.hide;
    end

    cgo=mdladv.getTaskObj(cgoGroupId);
    if~isa(cgo,'CodeGenAdvisor.Group')
        disp('Failed to obtain the code generation group');
        return;
    end

    cgo.model=mdladv.SystemHandle;
    cgo.CGONum=length(checkID);
    cgo.Objectives=hConfigSet.get_param('ObjectivePriorities');
    cgo.ERTObj=[];
    cgo.isERT=ertTargetCode;
    cgo.Enable=false;
    cgo.runMode=mode;
    cgo.initChecks;
    numOfChecksToRun=coder.advisor.internal.selectChecks(cgo,opId,hConfigSet);

    issuesFound=false;
    if toRun
        if~rtwgenMode
            cgo.runTaskAdvisor;
            if~isempty(cgo.cgirCheckIdx)
                Advisor.RegisterCGIRInspectors.getInstance.addInspectors(cgo.cgirCheckIds);
            end
        else
            if~isempty(cgo.cgirCheckIdx)
                taskIdx={};
                for i=cgo.cgirCheckIdx
                    taskObj=cgo.MAObj.TaskAdvisorCellarray{i};
                    for j=1:length(cgo.ChildrenObj)
                        if strcmp(cgo.ChildrenObj{j}.MAC,taskObj.MAC)
                            taskIdx{end+1}=taskObj.Index;%#ok<AGROW>
                            break;
                        end
                    end
                    parent=taskObj.parentObj;
                end
                cgo.MAObj.HasCGIRed=true;
                if~isempty(taskIdx)
                    cgo.MAObj.runCheck(taskIdx,true,parent);
                end
                cgo.MAObj.HasCGIRed=false;

                Advisor.RegisterCGIRInspectors.getInstance.clearInspectors;
                Advisor.RegisterCGIRInspectorResults.getInstance.clearResults;
            end
        end
        resultCellArray=cell(1,numOfChecksToRun);
        fixedLength=length('com.mathworks.cgo');
        for i=1:numOfChecksToRun
            id=cgo.Children{i};
            id_num=str2double(id(fixedLength+2:end));
            checkName=checkID{id_num};

            a.checkID=checkName;
            a.result=mdladv.getCheckResultStatus(checkName);
            if cgo.ChildrenObj{i}.Selected&&~a.result



                issuesFound=true;
            end
            resultCellArray{i}=a;
        end
    end

    if alwaysDisplay||issuesFound
        ret=false;
        mdladv.displayExplorer;

        explorer=mdladv.MAExplorer;
        if ishandle(hSys)
            modelName=get_param(hSys,'name');
        else
            modelName=hSys;
        end
        explorer.Title=[DAStudio.message('RTW:configSet:CGAName'),' - ',modelName];
        explorer.setRoot(cgo);

        action=find(explorer,'-isa','DAStudio.Action');

        for i=1:length(action)
            if~isequal(action(i).text,DAStudio.message('Simulink:tools:MAExit'))&&...
                ~isequal(action(i).text,DAStudio.message('ModelAdvisor:engine:CodeGenAdvisorHelp'))&&...
                ~isequal(action(i).text,DAStudio.message('Simulink:tools:MAModelAdvisorHelp'))&&...
                ~isequal(action(i).text,DAStudio.message('Simulink:tools:MAAboutSimulink'))&&...
                ~isequal(action(i).text,DAStudio.message('Simulink:tools:MARunSelectedChecks'))&&...
                ~isequal(action(i).text,DAStudio.message('Simulink:tools:MARunThisCheck'))&&...
                ~isequal(action(i).text,DAStudio.message('Simulink:tools:MAFindNext'))&&...
                ~isequal(action(i).text,DAStudio.message('Simulink:tools:MAFindPrevious'))
                action(i).Enable='off';
            end
        end
    end

    if toRun
        result=resultCellArray;
    else
        result=[];
    end
    successful=ret;
    return;
end


