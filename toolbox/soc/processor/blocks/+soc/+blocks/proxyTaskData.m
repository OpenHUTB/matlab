function res=proxyTaskData(action,varargin)




    persistent SOC_PROXY_TASK_MAP
    res=[];
    switch action
    case 'get'
        mdl=varargin{1};


        refMdls=find_mdlrefs(mdl,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
        idx=0;
        for i=1:numel(refMdls)
            mdl=refMdls{i};
            if~isempty(SOC_PROXY_TASK_MAP)&&...
                SOC_PROXY_TASK_MAP.isKey(mdl)
                theseProxyTasks=SOC_PROXY_TASK_MAP(mdl);
                for j=1:numel(theseProxyTasks)
                    idx=idx+1;
                    res.proxyTask(idx)=theseProxyTasks(j);
                end
            end
        end
    case 'clear'
        mdl=varargin{1};
        if~isempty(SOC_PROXY_TASK_MAP)&&SOC_PROXY_TASK_MAP.isKey(mdl)
            SOC_PROXY_TASK_MAP(mdl)=[];
        end
    case 'init'
        mdl=varargin{1};
        if~isempty(SOC_PROXY_TASK_MAP)&&SOC_PROXY_TASK_MAP.isKey(mdl)
            SOC_PROXY_TASK_MAP(mdl)=[];
        end
    case 'addProxyTask'
        blkHdl=varargin{1};
        mdl=get_param(bdroot(blkHdl),'Name');
        maskType=get_param(blkHdl,'MaskType');
        if isequal(maskType,'ProxyTask')
            sampleTime=get_param(blkHdl,'SampleTime');
            taskType=get_param(blkHdl,'TaskType');
        else
            sampleTime=0;
            taskType='';
        end
        newProxyTask.BlockHandle=blkHdl;
        newProxyTask.MaskType=maskType;
        newProxyTask.TaskType=taskType;
        newProxyTask.SampleTime=str2double(sampleTime);
        if isempty(SOC_PROXY_TASK_MAP)
            SOC_PROXY_TASK_MAP=...
            containers.Map('KeyType','char','ValueType','any');
        end
        if~SOC_PROXY_TASK_MAP.isKey(mdl)
            SOC_PROXY_TASK_MAP(mdl)=newProxyTask;
        else
            SOC_PROXY_TASK_MAP(mdl)=[SOC_PROXY_TASK_MAP(mdl),newProxyTask];
        end
    end
