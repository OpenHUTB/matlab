function setDlg(h,dlg)

    if~h.GUI||~isa(dlg,'DAStudio.Dialog')
        return;
    end

    name=h.Name;
    status=h.Status;
    if length(status)>25
        status(12:end)='';
    end

    dlg.setWidgetValue(strcat('s_',h.Name),...
    DAStudio.message(strcat('configset:util:Status_',status)));

    if isempty(h.DiffNum)
        dlg.setWidgetValue(strcat('d_',h.Name),'');
    elseif h.DiffNum==0||h.DiffNum==1
        dlg.setWidgetValue(strcat('d_',h.Name),...
        DAStudio.message('configset:util:ShowDiff',h.DiffNum));
    elseif h.DiffNum>1
        dlg.setWidgetValue(strcat('d_',h.Name),...
        DAStudio.message('configset:util:ShowDiffs',h.DiffNum));
    end

    if~strcmp(status,'Failed')
        try
            delete(h.ErrDlg);
        catch %#ok
        end
    end

    switch status
    case 'Converted'
        dlg.setEnabled(strcat('r_',name),false);
        dlg.setEnabled(strcat('u_',name),true);

        dlg.setVisible(strcat('n_',name),true);
        dlg.setVisible(strcat('e_',name),false);

        if isempty(h.DiffNum)

            dlg.setVisible(strcat('d_',name),false);
            dlg.setVisible(strcat('nr',name),false);
        elseif~isnan(h.DiffNum)

            dlg.setVisible(strcat('d_',name),true);
            dlg.setVisible(strcat('nr',name),false);
        else

            dlg.setVisible(strcat('nr',name),true);
            dlg.setVisible(strcat('d_',name),false);
        end
        dlg.setVisible(strcat('pc',name),true);
        dlg.setVisible(strcat('ps',name),false);
        dlg.setVisible(strcat('pf',name),false);
        dlg.setVisible(strcat('pp',name),false);
        dlg.setVisible(strcat('pw',name),false);

    case 'Restored'
        dlg.setEnabled(strcat('r_',name),true);
        dlg.setEnabled(strcat('u_',name),false);

        dlg.setVisible(strcat('nr',name),false);
        dlg.setVisible(strcat('d_',name),false);
        dlg.setVisible(strcat('e_',name),false);

        dlg.setVisible(strcat('ps',name),true);
        dlg.setVisible(strcat('pc',name),false);
        dlg.setVisible(strcat('pf',name),false);
        dlg.setVisible(strcat('pp',name),false);
        dlg.setVisible(strcat('pw',name),false);

    case 'Skipped'
        dlg.setEnabled(strcat('r_',name),false);
        dlg.setEnabled(strcat('u_',name),false);

        dlg.setVisible(strcat('nr',name),false);
        dlg.setVisible(strcat('d_',name),false);
        dlg.setVisible(strcat('e_',name),false);

        dlg.setVisible(strcat('ps',name),true);
        dlg.setVisible(strcat('pc',name),false);
        dlg.setVisible(strcat('pf',name),false);
        dlg.setVisible(strcat('pp',name),false);
        dlg.setVisible(strcat('pw',name),false);

    case 'Initial'
        dlg.setEnabled(strcat('r_',name),false);
        dlg.setEnabled(strcat('u_',name),false);

        dlg.setVisible(strcat('nr',name),false);
        dlg.setVisible(strcat('d_',name),false);
        dlg.setVisible(strcat('e_',name),false);

        dlg.setVisible(strcat('ps',name),true);
        dlg.setVisible(strcat('pc',name),false);
        dlg.setVisible(strcat('pf',name),false);
        dlg.setVisible(strcat('pp',name),false);
        dlg.setVisible(strcat('pw',name),false);

    case 'InProgress'
        dlg.setEnabled(strcat('r_',name),false);
        dlg.setEnabled(strcat('u_',name),false);

        dlg.setVisible(strcat('nr',name),false);
        dlg.setVisible(strcat('d_',name),false);
        dlg.setVisible(strcat('e_',name),false);

        dlg.setVisible(strcat('pp',name),true);
        dlg.setVisible(strcat('pc',name),false);
        dlg.setVisible(strcat('ps',name),false);
        dlg.setVisible(strcat('pf',name),false);
        dlg.setVisible(strcat('pw',name),false);

    case 'Waiting'
        dlg.setEnabled(strcat('r_',name),false);
        dlg.setEnabled(strcat('u_',name),false);

        dlg.setVisible(strcat('nr',name),false);
        dlg.setVisible(strcat('d_',name),false);
        dlg.setVisible(strcat('e_',name),false);

        dlg.setVisible(strcat('pw',name),true);
        dlg.setVisible(strcat('pp',name),false);
        dlg.setVisible(strcat('pc',name),false);
        dlg.setVisible(strcat('ps',name),false);
        dlg.setVisible(strcat('pf',name),false);
    end

    if h.Fail
        dlg.setWidgetValue(strcat('n_',name),' ');
        dlg.setVisible(strcat('nr',name),false);
        dlg.setVisible(strcat('d_',name),false);
        dlg.setVisible(strcat('e_',name),true);
        switch status
        case 'Initial'
            dlg.setWidgetValue(strcat('e_',name),DAStudio.message('configset:util:ConvertionFailed'));
        case 'Converted'
            dlg.setWidgetValue(strcat('e_',name),DAStudio.message('configset:util:UndoFailed'));
        case 'Restored'
            dlg.setWidgetValue(strcat('e_',name),DAStudio.message('configset:util:RedoFailed'));
        end

    end
