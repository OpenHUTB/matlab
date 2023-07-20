function search(h)



    dlg=h.Dialog;
    name=dlg.getWidgetValue('searchInput');

    vs=h.Map.values;
    for i=1:length(vs)
        v=vs{i};
        k=regexpi(v.Name,name);
        if~isempty(name)&&isempty(k)
            dlg.setVisible(strcat('a_',v.Name),false);
        else
            dlg.setVisible(strcat('a_',v.Name),true);
        end
    end

    dlg.setWidgetValue('Status',DAStudio.message('configset:util:TopPan_Status'));
