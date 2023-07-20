function launchCFunctionPrototypeControl(model,hDlg,highlightTag)



    if ischar(model)
        load_system(strtok(model,'/'));
        model=get_param(model,'handle');
    end
    if nargin<2
        hDlg=[];
    end


    if strcmp(get_param(model,'type'),'block')
        RTW.configSubsystemBuild(model);
        fcnclass=get_param(model,'SSRTWFcnClass');
    else
        fcnclass=get_param(model,'RTWFcnClass');
        if(isa(fcnclass,'RTW.FcnDefault')||...
            isa(fcnclass,'RTW.ModelSpecificCPrototype'))&&...
            isa(fcnclass.ViewWidget,'DAStudio.Dialog')
            fcnclass.ViewWidget.show();
        else
            if~isa(fcnclass,'RTW.ModelSpecificCPrototype')&&...
                ~isa(fcnclass,'RTW.FcnDefault')
                fcnclass=RTW.FcnDefault('',model);


                dirtyFlag=get_param(model,'Dirty');
                set_param(model,'RTWFcnClass',fcnclass);
                set_param(model,'Dirty',dirtyFlag);
            else
                if~ishandle(fcnclass.ModelHandle)||...
                    fcnclass.ModelHandle~=model
                    fcnclass.ModelHandle=model;
                end
            end
            fcnclassUI=RTW.FcnCtlUI(fcnclass,hDlg);
            fcnclass.ViewWidget=DAStudio.Dialog(fcnclassUI);
        end
    end

    if nargin>=3


        fcnclass.ViewWidget.enableWidgetHighlight(highlightTag,[0,175,255,255]);
    end
end

