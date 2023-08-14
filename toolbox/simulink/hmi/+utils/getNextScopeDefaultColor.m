function defaultColor=getNextScopeDefaultColor(mdl,widgetID,isLibWidget)



    if ischar(widgetID)
        defaultColor=locLegacyNextScopeDefaultColor(mdl,widgetID,isLibWidget);
    else
        defaultColor=locCoreBlockNextScopeDefaultColor(widgetID);
    end
end


function defaultColor=locCoreBlockNextScopeDefaultColor(hBlk)
    selColors=Simulink.sdi.Map;
    numChecked=0;

    dlg=hmiblockdlg.DashboardScope.findScopeDialog(hBlk);
    for idx=1:length(dlg.SelectedSignals)
        if strcmpi(dlg.SelectedSignals{idx}.checked,'true')&&...
            ~strcmpi(dlg.SelectedSignals{idx}.isDefaultColorAndStyle,'true')
            selColors.insert(num2str(dlg.SelectedSignals{idx}.lineColor),true);
            numChecked=numChecked+1;
        end
    end

    defaultColor=locGetDefaultColor(selColors,numChecked);
end


function defaultColor=locLegacyNextScopeDefaultColor(mdl,widgetID,isLibWidget)
    modelHandle=get_param(mdl,'Handle');
    signalInfo=Simulink.HMI.WebHMI.getAllSignals(modelHandle,widgetID,isLibWidget);
    selColors=Simulink.sdi.Map;
    numChecked=0;
    for idx=1:length(signalInfo)
        if signalInfo(idx).Selected
            selColors.insert(num2str(signalInfo(idx).LineColor),true);
            numChecked=numChecked+1;
        end
    end
    defaultColor=locGetDefaultColor(selColors,numChecked);
end


function defaultColor=locGetDefaultColor(selColors,numChecked)

    defaultColors=sdi.Repository.getDefaultColors();
    for idx=1:length(defaultColors)
        curColor=int32(defaultColors{idx}*255);
        if~selColors.isKey(num2str(curColor))
            defaultColor=defaultColors{idx};
            return
        end
    end


    defClrIdx=mod(numChecked,length(defaultColors))+1;
    defaultColor=defaultColors{defClrIdx};
end

