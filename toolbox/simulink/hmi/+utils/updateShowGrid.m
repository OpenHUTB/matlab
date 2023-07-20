function updateShowGrid(dlg,showGridValue)




    dlg.setWidgetValue('ShowGrid',showGridValue);
    dlg.clearWidgetDirtyFlag('showGrid');
    dlg.enableApplyButton(false,false);
end