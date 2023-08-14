function updateFitToView(dlg,fitToView)




    dlg.setWidgetValue('DispFitToView',fitToView);
    dlg.clearWidgetDirtyFlag('DispFitToView');
    dlg.enableApplyButton(false,false);
end