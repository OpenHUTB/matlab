function[defaultVals,complexFormat]=getDefaultValues(dlgUUID)




    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    bShowUsage=true;
    for i=1:length(dlgs)
        if Simulink.sdi.internal.sigSettingsDlg.isSigSettingsDlg(dlgs(i))
            if dlgUUID==dlgs(i).getSource.DlgUUID
                dlgSrc=dlgs(i).getSource;
                sigInfo=dlgSrc.SigInfo;
                bShowUsage=false;
                bShowSubplot=bShowUsage;
            end
        end
    end
    [client,~,~]=Simulink.sdi.internal.Utils.getWebClient(sigInfo);
    defaultLS=client.ObserverParams.LineSettings;
    defaultVals.LineStyle=defaultLS.LineStyle;
    if isfield(defaultLS,'LineWidth')
        defaultVals.LineWidth=defaultLS.LineWidth;
    end
    defaultVals.ColorString=defaultLS.ColorString;
    defaultVals.Axes=defaultLS.Axes;
    defaultVals.ShowUsage=bShowUsage;
    defaultVals.ShowSubplot=bShowSubplot;

    complexFormat=0;
    if isfield(client.ObserverParams,'ComplexFormat')
        complexFormat=client.ObserverParams.ComplexFormat;
    end
end
