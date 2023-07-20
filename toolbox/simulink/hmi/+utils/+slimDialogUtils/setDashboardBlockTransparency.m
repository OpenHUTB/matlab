function setDashboardBlockTransparency(dlg,obj,paramName,paramVal)
    param=strtrim(paramVal);
    opacity=str2double(paramVal);
    if(opacity>=0&&opacity<=1)
        dlg.clearWidgetWithError(paramName);
        dlg.clearWidgetDirtyFlag(paramName);
        obj.getBlock().Opacity=paramVal;

        signalDlgs=obj.getOpenDialogs(true);
        for j=1:length(signalDlgs)
            otherDlg=signalDlgs{j};
            if~isequal(dlg,signalDlgs{j})
                otherDlg.clearWidgetWithError(paramName);
                otherDlg.setWidgetValue(paramName,param);
                otherDlg.clearWidgetDirtyFlag(paramName);
                otherDlg.enableApplyButton(false,false);
            end
        end
    else
        errormsg=DAStudio.message('SimulinkHMI:dialogs:DashboardBlockInvalidOpacity');
        dlg.setWidgetWithError('opacity',...
        DAStudio.UI.Util.Error('Opacity','Error',errormsg,[255,0,0,100]));
        return;
    end
end