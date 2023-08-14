function success=runAction(this,checkTitleID,varargin)





    Simulink.ModelAdvisor.getActiveModelAdvisorObj(this);


    if isa(varargin{1},'ModelAdvisor.Task')
        checkObj=varargin{1}.Check;
    else
        checkObj=this.getCheckObj(checkTitleID);
    end


    if~isempty(checkObj)&&isempty(checkObj.Callback)
        am=Advisor.Manager.getInstance;
        am.loadCachedFcnHandle(checkObj);
    end

    if isempty(checkObj)
        success=false;
        disp(DAStudio.message('Simulink:tools:MAInvalidCheckID'));
    elseif isempty(checkObj.Action.CallbackHandle)
        success=false;
        disp(DAStudio.message('Simulink:tools:NoActionCallBack',checkTitleID));
    else
        this.ActiveCheck=checkObj;
        this.ActiveCheckID=checkObj.Index;
        origStage=this.stage;
        this.stage='ExecuteActionCallback';
        try
            result=checkObj.Action.CallbackHandle(varargin{1:end});
            if iscell(result)
                checkObj.Action.ResultInHTML=...
                modeladvisorprivate('modeladvisorutil2','emitHTMLforMAElements',result{:});
            else
                checkObj.Action.ResultInHTML=...
                modeladvisorprivate('modeladvisorutil2','emitHTMLforMAElements',result);
            end
            if isa(varargin{1},'ModelAdvisor.Node')&&isvalid(varargin{1})
                if this.ResetAfterAction
                    varargin{1}.updateStates(ModelAdvisor.CheckStatus.NotRun);
                end
                checkObj.Action.Enable=false;
            end
            success=true;
        catch E
            success=false;
            checkObj.Action.Success=false;
            checkObj.Action.ResultInHTML=E.message;
            disp(DAStudio.message('Simulink:tools:MAErrorInActionCallback',checkObj.Title));
            disp(E.message);
        end
        this.stage=origStage;
    end
