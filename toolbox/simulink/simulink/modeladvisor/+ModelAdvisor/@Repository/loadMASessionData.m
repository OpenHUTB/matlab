

function CacheDependantInputParam=loadMASessionData(obj,varargin)
    PerfTools.Tracer.logMATLABData('MAGroup','Load MA Session Data',true);

    savedCopy=obj.loadLatestData('MdladvInfo');
    if nargin>1
        CacheDependantInputParam=loc_loadMASessionData(obj,savedCopy,varargin{1});
    else



        CacheDependantInputParam=loc_loadMASessionData(obj,savedCopy,'Check');
        loc_loadMASessionData(obj,savedCopy,'TaskAdvisor');
        loc_loadMASessionData(obj,savedCopy,'R2F');
    end

    PerfTools.Tracer.logMATLABData('MAGroup','Load MA Session Data',false);
end

function CacheDependantInputParam=loc_loadMASessionData(obj,savedCopy,phase)
    CacheDependantInputParam={};
    switch phase
    case 'Check'

        cacheCheckCellArray=obj.MAObj.CheckCellArray;
        for i=1:length(cacheCheckCellArray)
            DependantInputParam=loadCheckData(cacheCheckCellArray{i},savedCopy.recordCellArray{i},i);
            if~isempty(DependantInputParam)
                CacheDependantInputParam=[CacheDependantInputParam,DependantInputParam];%#ok<AGROW>
            end
        end
        obj.MAObj.CheckCellArray=cacheCheckCellArray;
        for i=1:length(obj.MAObj.TaskCellArray)
            obj.MAObj.TaskCellArray{i}.Selected=savedCopy.taskCellArray{i}.Selected;
        end
        obj.MAObj.StartInTaskPage=savedCopy.StartInTaskPage;
    case 'TaskAdvisor'
        if isfield(savedCopy,'TaskAdvisorCellArray')
            TaskAdvisorCellArray=obj.MAObj.TaskAdvisorCellArray;
            if length(savedCopy.TaskAdvisorCellArray)==length(TaskAdvisorCellArray)
                for i=1:length(TaskAdvisorCellArray)


                    TaskAdvisorCellArray{i}.State=savedCopy.TaskAdvisorCellArray{i}.State;
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
            obj.MAObj.TaskAdvisorCellArray=TaskAdvisorCellArray;

            modeladvisorprivate('modeladvisorutil2','CalculateTreeInitStatus',obj.MAObj.TaskAdvisorRoot);
        end
    case 'R2F'

        obj.MAObj.R2FMode=savedCopy.R2FInfo.R2FMode;
        obj.MAObj.R2FStart=obj.MAObj.getTaskObj(savedCopy.R2FInfo.R2FStart);
        obj.MAObj.R2FStop=obj.MAObj.getTaskObj(savedCopy.R2FInfo.R2FStop);

        if isfield(savedCopy,'MAExplorerPosition')
            obj.MAObj.MAExplorerPosition=savedCopy.MAExplorerPosition;
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
        if~strcmp(savedData.ActionResultInHTML,'not exist')
            checkObj.Action.ResultInHTML=savedData.ActionResultInHTML;
        end
        checkObj.ProjectResultData=savedData.ProjectResultData;
    end
end