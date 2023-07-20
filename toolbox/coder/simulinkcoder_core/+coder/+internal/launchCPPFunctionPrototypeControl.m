function launchCPPFunctionPrototypeControl(model,highlightTag)



    if ischar(model)
        model=load_system(model);
    end
    fcnclass=get_param(model,'RTWCPPFcnClass');
    if isa(fcnclass,'RTW.ModelCPPClass')&&...
        isa(fcnclass.ViewWidget,'DAStudio.Dialog')
        fcnclass.ViewWidget.show();
    else
        if~isa(fcnclass,'RTW.ModelCPPClass')
            fcnclass=RTW.ModelCPPDefaultClass('',model);


            dirtyFlag=get_param(model,'Dirty');
            set_param(model,'RTWCPPFcnClass',fcnclass);
            set_param(model,'Dirty',dirtyFlag);
        else
            if~ishandle(fcnclass.ModelHandle)||fcnclass.ModelHandle~=model
                fcnclass.ModelHandle=model;
            end
        end
        fcnclassUI=RTW.CPPFcnCtlUI(fcnclass);
        fcnclass.ViewWidget=DAStudio.Dialog(fcnclassUI);
    end

    if nargin>=2


        fcnclass.ViewWidget.enableWidgetHighlight(highlightTag,[0,175,255,255]);
    end
end

