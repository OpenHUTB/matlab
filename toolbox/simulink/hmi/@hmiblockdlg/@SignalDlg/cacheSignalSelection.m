


function cacheSignalSelection(widgetId,model,srcBlockHandle,outputPortIndex)

    srcBlockHandle=str2double(srcBlockHandle);
    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;


        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            dlgSrc.srcBlockObj=get_param(srcBlockHandle,'Object');
            dlgSrc.OutputPortIndex=outputPortIndex;
            signalDlgs=dlgSrc.getOpenDialogs(true);



            for j=1:length(signalDlgs)
                if(isa(signalDlgs{j},'DAStudio.Dialog'))
                    signalDlgs{j}.enableApplyButton(true,true);
                end
            end
            channel=hmiblockdlg.SignalDlg.getChannel();
            message.publish([channel,'changeSelectedRow'],...
            {widgetId,srcBlockHandle,outputPortIndex});
            break;
        end
    end
end
