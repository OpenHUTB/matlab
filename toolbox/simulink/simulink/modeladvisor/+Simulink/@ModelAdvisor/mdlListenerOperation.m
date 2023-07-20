function listener=mdlListenerOperation(this,method,varargin)






    persistent mdllistener;



    if nargin>2
        callBackFcn=varargin{1};
    else
        callBackFcn=@LocalCloseCB;
    end

    switch method
    case{'DettachListener'}
        if isa(mdllistener,'handle.listener')||isa(mdllistener,'event.listener')
            mdllistener.delete;
        end
    case{'AttachListener'}
        if isa(mdllistener,'handle.listener')||isa(mdllistener,'event.listener')
            mdllistener.delete;
        end

        mdlObj=get_param(bdroot(this.System),'Object');
        mdllistener=Simulink.listener(mdlObj,'CloseEvent',callBackFcn);
    end

    listener=mdllistener;





    function LocalCloseCB(eventSrc,eventData)%#ok<INUSD>
        mdladvObj=eventSrc.getModelAdvisorObj;

        mdladvObj.closeExplorer;

        if mdladvObj.runInBackground&&ModelAdvisor.isRunning
            parallelRun=ModelAdvisor.ParallelRun.getInstance();
            parallelRun.cancelRun();
        end
        if isa(mdladvObj.MAExplorer,'DAStudio.Explorer')
            mdladvObj.MAExplorer.delete;
        end
        if isa(mdladvObj.ListExplorer,'DAStudio.Explorer')
            mdladvObj.ListExplorer.delete;
        end
        if isa(mdladvObj.RPObj,'ModelAdvisor.RestorePoint')
            mdladvObj.RPObj.delete;
        end

        if~isa(mdladvObj.ConfigUIWindow,'DAStudio.Explorer')
            Simulink.ModelAdvisor.getActiveModelAdvisorObj([]);
        end
        modeladvisorprivate('modeladvisorutil2','SaveTaskAdvisorMiniInfo',mdladvObj);

        if isa(mdladvObj.Database,'ModelAdvisor.Repository')
            delete(mdladvObj.Database);
        end
