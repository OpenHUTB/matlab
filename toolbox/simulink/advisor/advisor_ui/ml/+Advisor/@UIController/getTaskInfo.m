function result=getTaskInfo(this,taskId)
    result=struct();
    if strcmpi(taskId,this.maObj.TaskAdvisorRoot.ID)
        taskObj=this.maObj.TaskAdvisorRoot;
    else
        taskObj=this.maObj.getTaskObj(taskId);
    end

    result.title=taskObj.DisplayName;
    if~isempty(taskObj.Description)
        result.description=regexprep(taskObj.Description,'<br\s*/?>',newline);
    elseif isa(taskObj,'ModelAdvisor.Task')&&~isempty(taskObj.Check)&&isprop(taskObj.Check,'TitleTips')&&~isempty(taskObj.Check.TitleTips)
        result.description=regexprep(taskObj.Check.Description,'<br\s*/?>',newline);
    else
        result.description='';
    end

    result.status=ModelAdvisor.CheckStatusUtil.getText(taskObj.State);
    result.icon=['/',taskObj.getDisplayIcon];

    if isa(taskObj,'ModelAdvisor.Task')
        result.checkId=taskObj.check.ID;
        result.report=getCheckReport(this,taskObj);
        result.hasFix=~isempty(taskObj.check.Action)&&taskObj.state~=ModelAdvisor.CheckStatus.NotRun&&taskObj.state~=ModelAdvisor.CheckStatus.Passed;
        result.hasJustify=taskObj.state~=ModelAdvisor.CheckStatus.NotRun&&taskObj.state~=ModelAdvisor.CheckStatus.Passed;
    else
        result.checkId='';
        result.report=getFolderReport(taskObj);
        result.hasFix=false;
        result.hasJustify=false;
    end
    result.selected=taskObj.Selected;
    result.inputParams=getInputParameters(taskObj);
    result.inputParamGrid=getInputParamGrid(taskObj);
end

function result=getCheckReport(this,taskObj)
    checkObj=taskObj.check;


    if isempty(checkObj.ResultDetails)
        loadedResults=this.maObj.Database.loadData('resultdetails','TaskID',taskObj.ID);
        checkObj.setResultDetails(loadedResults);
    end

    result=getResultStruct();
    result.isFolder=false;
    result.CheckContent=checkObj.ResultInHTML;
    result.TabularData=[];
    result.CheckSummary=[];


    if strcmp(checkObj.CallbackStyle,'DetailStyle')&&taskObj.state~=ModelAdvisor.CheckStatus.NotRun
        result.TabularData=arrayfun(@(x)getViolationRow(this,x,taskObj),checkObj.ResultDetails,'UniformOutput',0);
        result.CheckSummary=getCounts(arrayfun(@(x)ModelAdvisor.CheckStatusUtil.getText(x.ViolationType),checkObj.ResultDetails,'UniformOutput',0));
    end

    result.supportsTabular=strcmp(checkObj.CallbackStyle,'DetailStyle');

    if isempty(result.CheckContent)
        result.CheckContent='<p>Not Run</p>';
    end

    result.justification=getJustification(this,checkObj.ID);
end

function result=getFolderReport(taskObj)
    result.isFolder=true;
    result.FolderSummary=[];
    SLversion=ver('Simulink');
    result.FolderSummary.SimulinkVersion=SLversion.Version;
    result.FolderSummary.ModelVersion=get_param(bdroot(taskObj.MAObj.System),'ModelVersion');
    if taskObj.RunTime==0
        result.FolderSummary.TimeStamp='-';
    else
        result.FolderSummary.TimeStamp=loc_getDateString(taskObj.MAObj.RunTime);
    end
    result.FolderSummary.ReportFileName=modeladvisorprivate('modeladvisorutil2','GetReportNameForTaskNode',...
    taskObj,taskObj.MAObj.AtticData.WorkDir);
    result.FolderSummary.Stats=[];

    children=taskObj.getAllChildren();

    children=children(cellfun(@(y)~isempty(y.Check),children,'UniformOutput',1));
    statusArr=cellfun(@(x)ModelAdvisor.CheckStatusUtil.getText(x.Check.status),children,'UniformOutput',0);
    result.FolderSummary.Stats=getCounts(statusArr);
end

function inputParams=getInputParameters(taskObj)
    if isa(taskObj,'ModelAdvisor.Task')
        inputParams=taskObj.Check.getInputParameters();
    else
        inputParams=taskObj.getInputParameters();
    end
    if~iscell(inputParams)
        inputParams={inputParams};
    end
    inputParams=cellfun(@(x)x.toStruct,inputParams);
end

function result=getInputParamGrid(taskObj)
    if isa(taskObj,'ModelAdvisor.Task')
        result=taskObj.Check.InputParametersLayoutGrid;
    else
        result=taskObj.InputParametersLayoutGrid;
    end
end

function dateString=loc_getDateString(timeInfo)
    locale=feature('locale');
    lang=locale.messages;

    if strncmpi(lang,'ja',2)||strncmp(lang,'zh_CN',5)||strncmpi(lang,'ko_KR',5)
        dateString=datestr(timeInfo,'yyyy/mm/dd HH:MM:SS');
    else
        dateString=datestr(timeInfo);
    end
end

function result=getResultStruct()

    result=struct(...
    'isFolder',false,...
    'FolderSummary',[],...
    'CheckStatus','',...
    'CheckStatusIcon','',...
    'CheckContent','',...
    'CheckSummary',[],...
    'TabularData',[],...
    'supportsTabular',false);
end

function row=getViolationRow(this,RDObj,taskObj)
    sid=ModelAdvisor.ResultDetail.getData(RDObj);
    data.id=RDObj.ID;
    if~isempty(sid)
        templ=ModelAdvisor.FormatTemplate('ListTemplate');
        fEntry=templ.formatEntry(sid);
        if isa(fEntry,'ModelAdvisor.Text')
            data.value=fEntry.Content;
        else
            try
                data.value=Simulink.ID.getFullName(sid);
            catch
                data.value='';
            end
        end
    else
        data.value=sid;
    end

    manager=slcheck.getAdvisorJustificationManager(this.rootmodel);
    RDJust=manager.getAdvisorFilterSpecification(advisor.filter.FilterType.Block,RDObj.getHash(),taskObj.Check.ID);
    if~isempty(RDJust)
        comment=RDJust(1).metadata.summary;
    else
        comment='';

        if(taskObj.Check.status==ModelAdvisor.CheckStatus.Justified)
            filter=manager.getAdvisorFilterSpecification(advisor.filter.FilterType.Block,taskObj.Check.ID,taskObj.Check.ID);
            if~isempty(filter)&&RDObj.getViolationStatus~=ModelAdvisor.CheckStatus.Passed
                comment=filter.metadata.summary;
            end
        end
    end

    statusMsg=regexprep(RDObj.Description,'<br\s*/?>',newline);
    recAction=regexprep(RDObj.RecAction,'<br\s*/?>',newline);

    row={RDObj.ID,['/',ModelAdvisor.CheckStatusUtil.getIcon(RDObj.ViolationType,'resultdetails')],data,statusMsg,recAction,comment};
end

function stats=getCounts(statuses)
    allCatsE=flip(enumeration(ModelAdvisor.CheckStatus.Passed));
    allCats=arrayfun(@(x)ModelAdvisor.CheckStatusUtil.getText(x),allCatsE,'UniformOutput',0);
    count=zeros(1,numel(allCats));
    for i=1:numel(statuses)
        idx=strcmp(allCats,statuses{i});
        count(idx)=count(idx)+1;
    end
    stats=[];
    for i=1:numel(allCats)
        if count(i)>0
            stats(end+1).name=allCats{i};%#ok<AGROW>
            stats(end).count=count(i);
            stats(end).color=ModelAdvisor.CheckStatusUtil.getStatusColor(allCatsE(i));
        end
    end
end

function justification=getJustification(this,checkId)
    justification=struct('message','','user','','timestamp','');
    manager=slcheck.getAdvisorJustificationManager(this.rootmodel);
    filter=manager.getAdvisorFilterSpecification(...
    advisor.filter.FilterType.Block,checkId,checkId);
    if~isempty(filter)
        justification=struct('message',filter.metadata.summary,...
        'user',filter.metadata.user,...
        'timestamp',char(filter.metadata.timeStamp));
    end
end
