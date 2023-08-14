function searchByStatus(h,str)

    dlg=h.Dialog;
    vs=h.Map.values;
    for i=1:length(vs)
        v=vs{i};
        if~strcmp(str,'Failed')
            if strcmp(v.Status,str)||strcmp(str,'Total')
                dlg.setVisible(strcat('a_',v.Name),true);
            else
                dlg.setVisible(strcat('a_',v.Name),false);
            end
        else
            dlg.setVisible(strcat('a_',v.Name),v.Fail);
        end
    end

    if~strcmp(str,'Total')
        dlg.setWidgetValue('Status',...
        strcat(DAStudio.message('configset:util:TopPan_Status'),...
        ' (',...
        DAStudio.message(strcat('configset:util:Status_',str)),...
        ')'));
    else
        dlg.setWidgetValue('Status',DAStudio.message('configset:util:TopPan_Status'));
    end
