function closeInformer(this)
    this.ShowInformer=false;
    setpref('modeladvisor','ShowInformer',this.ShowInformer);
    if isa(this.ResultGUI,'DAStudio.Informer')
        modeladvisorprivate('modeladvisorutil2','CloseResultGUICallback');
        this.ResultGUI.delete;
    end

    editor=GLUE2.Util.findAllEditors(this.SystemName);
    if~isempty(editor)
        editor.closeNotificationByMsgID('modeladvisor.highlight.openconfigset');
    end
end