function dlg=getDialogSchema(obj)

    web.Type='webbrowser';
    web.Tag='SDPSetupTool';
    web.Url=obj.getUrl();

    if obj.debug
        web.DisableContextMenu=false;
        web.EnableInspectorInContextMenu=true;
        web.EnableInspectorOnLoad=true;
    else
        web.DisableContextMenu=true;
    end

    dlg.Items={web};
    dlg.DialogTitle=message('ToolstripCoderApp:sdpsetuptool:DialogTitle').getString;
    dlg.DisplayIcon=fullfile(matlabroot,'toolbox','shared',...
    'toolstrip_coder_app','plugin','icons','sdp','ModelHierarchy_Blue_24.png');
    dlg.Geometry=[200,200,800,480];
    dlg.Sticky=true;

    dlg.StandaloneButtonSet={'Ok','Cancel'};
    dlg.PreApplyMethod='apply';
    dlg.PreApplyArgs={};
    dlg.PreApplyArgsDT={};