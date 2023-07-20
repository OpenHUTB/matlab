function[isValid,msg]=preApplyCallback(this,~)

    isValid=true;
    msg='';



    project=oslc.Project.get(this.projName);


    queryBase=project.queryBase;
    if isempty(queryBase)
        msg=getString(message('Slvnv:oslc:ProjectAreaNameInvalid',this.projName));
        isValid=false;
        return;
    end

    if isempty(this.id)
        msg=getString(message('Slvnv:oslc:PleaseSelectValidId'));
        isValid=false;
        return;
    end

    try
        if~oslc.confirmContext(this.projName)
            msg=getString(message('Slvnv:oslc:ConfigContextUpdateDlgTitle'));
            isValid=false;
            return;
        end
    catch ex
        if strcmp(ex.identifier,'Slvnv:oslc:BrowserContextNotKnown')



            if project.confirmingConfig
                continueButtonName=getString(message('Slvnv:slreq:Continue'));
                dontAskButtonName=getString(message('Slvnv:oslc:DontAskAgain'));
                cancelButtonName=getString(message('Slvnv:slreq:Cancel'));
                reply=questdlg({ex.message,...
                getString(message('Slvnv:oslc:BrowserContextIfContinue')),...
                getString(message('Slvnv:oslc:ModuleContextDontAsk',dontAskButtonName))},...
                getString(message('Slvnv:oslc:DngLinkTarget')),...
                continueButtonName,dontAskButtonName,cancelButtonName,...
                continueButtonName);
                if isempty(reply)||strcmp(reply,cancelButtonName)
                    msg=ex.message;
                    isValid=false;
                    return;
                elseif strcmp(reply,dontAskButtonName)
                    project.confirmConfig(false);
                end
            else


            end
        else

            msg=ex.message;
            isValid=false;
            return;
        end
    end

    if isempty(this.moduleName)
        if project.usingModules
            if isempty(oslc.Requirement.registry(this.id(1)))
                continueButtonName=getString(message('Slvnv:slreq:Continue'));
                dontAskButtonName=getString(message('Slvnv:oslc:DontAskAgain'));
                cancelButtonName=getString(message('Slvnv:oslc:Cancel'));
                response=questdlg({getString(message('Slvnv:oslc:ModuleContextNotKnownFor',num2str(this.id(1)))),...
                getString(message('Slvnv:oslc:ModuleContextContinue')),...
                getString(message('Slvnv:oslc:ModuleContextDontAsk',dontAskButtonName))},...
                getString(message('Slvnv:oslc:ModuleContextNotSpecified')),...
                continueButtonName,dontAskButtonName,cancelButtonName,continueButtonName);
                if isempty(response)||strcmp(response,cancelButtonName)
                    isValid=false;
                    msg=getString(message('Slvnv:rmidata:RmiSlData:CanceledByUser'));
                    return;
                elseif strcmp(response,dontAskButtonName)
                    project.useModules(false);
                end
            end
        end
    end

    if length(this.id)>1&&~this.allowMultiselect
        msg=getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SelectionLinkTooManyObjects'));
        isValid=false;
        return;
    end


    for i=1:length(this.id)
        try
            req=oslc.getReqItem(this.id(i),this.projName,false);
            if isempty(req)
                msg=getString(message('Slvnv:oslc:FailedToFindIdInProject',num2str(this.id(i)),this.projName));
                isValid=false;
                return;
            else
                if isempty(this.reqs)
                    this.reqs=req;
                else
                    this.reqs(end+1)=req;
                end
            end
        catch Mex
            msg=Mex.message;
            isValid=false;
            return;
        end
    end

end
