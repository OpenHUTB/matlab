function remove_hook(~,dlg)





    if isempty(dlg.getWidgetValue('outputsList'))

        dlg.setWidgetValue('outputsList',0);
    end


end

