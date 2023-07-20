function widgetControlCallback(obj,dlg,tag)%#ok












    if strcmp(tag,'SaveVars2dSliceEnable')
        v=dlg.getWidgetValue('SaveVars2dSliceEnable');
        dlg.setEnabled('SaveVars2dSliceDimension1',v);
        dlg.setEnabled('SaveVars2dSliceDimension2',v);
    end


