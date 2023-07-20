function dlg=getConfigSetDialogSchema(hController,schemaName)




    hSrc=hController.getSourceObject;

    if~isempty(hSrc.getModel)

        fcnclass=get_param(hSrc.getModel,'RTWFcnClass');
        if~isempty(fcnclass)&&isa(fcnclass,'RTW.FcnCtl')
            if(ishandle(fcnclass.ViewWidget))
                fcnclass.ViewWidget.refresh;
            end
        end
    end

    dlg=hController.getConfigSetInfoDialogSchema(schemaName);
    dlg.DisableDialog=hSrc.isHierarchyReadonly||hSrc.isHierarchySimulating;
    if~isempty(hSrc.getModel)&&hSrc.isActive

        dlg.DisplayIcon='toolbox/shared/dastudio/resources/ActiveConfiguration_24.png';
    else

        dlg.DisplayIcon='toolbox/shared/dastudio/resources/Configuration_24.png';
    end

    helpdest='ConfigSet';
    dlg.HelpMethod='slprivate';
    dlg.HelpArgs={'configHelp','%dialog',hController,schemaName,helpdest};

    dlg.DefaultOk=false;

