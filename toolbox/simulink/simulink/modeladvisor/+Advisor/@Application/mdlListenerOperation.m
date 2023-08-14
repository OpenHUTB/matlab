function listnr=mdlListenerOperation(this,method,varargin)





    if nargin>2
        callBackFcn=varargin{1};
    else
        callBackFcn=@(src,evt)LocalCloseCB(this,src,evt);
    end

    switch method
    case{'DetachListener'}
        if isa(this.listener,'handle.listener')||isa(this.listener,'event.listener')
            this.listener.delete;
        end
    case{'AttachListener'}


        SubsysObj=get_param(this.AnalysisRoot,'Object');

        if isa(SubsysObj,'Simulink.BlockDiagram')
            this.listener=listener(SubsysObj,'CloseEvent',callBackFcn);
        else
            if strcmp(this.AdvisorId,'com.mathworks.Simulink.ModelReferenceAdvisor.MainGroup')

                model=Simulink.ID.getModel(this.AnalysisRoot);
                systemObj=get_param(model,'Object');
                this.listener=listener(systemObj,'CloseEvent',callBackFcn);
            else
                this.listener=Simulink.listener(SubsysObj,'DestroyEvent',callBackFcn);
            end
        end
    end

    listnr=this.listener;
end

function LocalCloseCB(app,~,~)
    maObj=app.getRootMAObj();



    if isa(maObj,'Simulink.ModelAdvisor')&&...
        isa(maObj.ConfigUIWindow,'DAStudio.Explorer')

    else
        app.delete();
    end
end
