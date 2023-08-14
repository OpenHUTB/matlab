function config_dlg_configure_param(action,hDlg,hSrc)



    if~isa(hSrc,'Simulink.BaseConfig')
        error(DAStudio.message('RTW:configSet:ConfigDlgParamError'));
    end

    model=hSrc.getModel;

    if isempty(model)
        return;
    end

    if~isa(hSrc,'Simulink.ConfigSet')
        hSrc=hSrc.getConfigSet;
    end
    hController=hSrc.getDialogController;
    dlgID=hController.ModelParameterConfigurationDialogID;

    switch action
    case 'Show'
        try
            if isempty(dlgID)
                eval(['dlgID = slwsprmattrib(''Create'',model,','hDlg);']);
                eval(['dlgID = slwsprmattrib(''reshow'',model,','hDlg, dlgID);']);
            else
                eval(['dlgID = slwsprmattrib(''reshow'',model,','hDlg, dlgID);']);
            end
        catch ME
            rethrow(ME);
        end

        hController.ModelParameterConfigurationDialogID=dlgID;

    case 'ParentClose'
        if slfeature('NewTunableParameterDialog')>0
            if~isempty(dlgID)||~isempty(ishandle(dlgID))
                dlg=dlgID.getDialogObj();
                if isequal(class(dlg),'DAStudio.Dialog')
                    dlg.delete;
                end
            end

            setappdata(0,get_param(model,'Name'),'');
            rmappdata(0,get_param(model,'Name'));
        elseif desktop('-inuse')
            if~isempty(dlgID)
                hd=findobj(allchild(0),'Title',...
                get(dlgID,'Title'));
                awtinvoke(dlgID,'dispose()');
                if ishandle(hd)
                    delete(hd);
                end
            end
        else
            if dlgID~=-1
                delete(dlgID);
            end
        end
    end



