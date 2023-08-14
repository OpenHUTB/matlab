function remove_hook(~,dlg)





    if isempty(dlg.getWidgetValue('assignedList'))

        dlg.setWidgetValue('assignedList',0);
    end


end

