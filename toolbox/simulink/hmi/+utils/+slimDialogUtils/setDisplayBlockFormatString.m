function setDisplayBlockFormatString(dlg,obj,paramName,paramVal)
    try
        obj.getBlock().FormatString=paramVal;
        dlg.clearWidgetDirtyFlag(paramName);
        dlg.clearWidgetWithError('formatString');
    catch me
        dlg.setWidgetWithError('formatString',...
        DAStudio.UI.Util.Error('FormatString','Error',me.message,[255,0,0,100]));
    end
end