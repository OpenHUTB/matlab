


function dlg=openDialog(cbinfo)


    mdl=cbinfo.userdata.mdl;
    portH=cbinfo.userdata.portH;
    sigInfo.mdl=mdl;
    sigInfo.portH=portH;


    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    for i=1:length(dlgs)
        if Simulink.sdi.internal.sigSettingsDlg.isSigSettingsDlg(dlgs(i))
            dlg=dlgs(i);
            if isequal(dlg.getSource.SigInfo,sigInfo)
                show(dlg);
                return
            end
        end
    end


    apiObj=Simulink.sdi.internal.ConnectorAPI.getAPI();
    if~apiObj.areControllersInitialized()
        start(apiObj)
    end
    dlgUUID=sdi.Repository.generateUUID();
    url=['toolbox/shared/sdi/web/MainView/sdi_signal_settings_dlg.html?dlgUUID=',dlgUUID];
    urlStr=getURL(apiObj,url);


    [client,~,~]=Simulink.sdi.internal.Utils.getWebClient(sigInfo);
    sigName=client.getLabel();
    title=[DAStudio.message('SDI:dialogs:SigSettingsTitle'),' ',sigName];


    portHPos=get_param(portH,'Position');
    try
        e=cbinfo.studio.App.getActiveEditor;
    catch me %#ok<NASGU>
        e=GLUE2.Util.findAllEditors(mdl);
    end
    c=e.getCanvas;
    viewRect=c.SceneRectInView;
    scale=c.Scale;
    globalRect=c.GlobalPosition;
    x=(portHPos(1)-viewRect(1))*scale+globalRect(1);
    y=(portHPos(2)-viewRect(2))*scale+globalRect(2);
    height=Simulink.sdi.internal.sigSettingsDlg.LogVisualizationDlg.getDefaultHeight(mdl);
    width=Simulink.sdi.internal.sigSettingsDlg.LogVisualizationDlg.getDefaultWidth(mdl);
    geometry=[x+25/scale,y-height/2,width,height];
    dlg=Simulink.sdi.internal.sigSettingsDlg.LogVisualizationDlg(...
    urlStr,...
    title,...
    geometry,...
    dlgUUID,...
    sigInfo);
end


