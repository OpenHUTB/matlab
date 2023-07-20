

function cacheParamSelection(widgetId,model,srcBlockHandle,srcParamOrVar,srcWksType)

    srcBlockHandle=str2double(srcBlockHandle);
    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            dlgSrc.srcBlockObj=get_param(srcBlockHandle,'object');
            dlgSrc.srcParamOrVar=srcParamOrVar;
            dlgSrc.srcWksType=srcWksType;
            dlgSrc.srcElement='';
            paramDlgs=dlgSrc.getOpenDialogs(true);



            for j=1:length(paramDlgs)
                paramDlgs{j}.enableApplyButton(true,true);
            end
            channel=hmiblockdlg.ParameterDlg.getChannel();
            message.publish([channel,'changeSelectedRow'],...
            {widgetId,srcBlockHandle,srcParamOrVar});
            break;
        end
    end
end
