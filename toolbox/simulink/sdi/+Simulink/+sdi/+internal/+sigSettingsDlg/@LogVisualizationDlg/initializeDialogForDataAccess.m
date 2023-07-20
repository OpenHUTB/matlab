function initializeDialogForDataAccess(this)



    if~isempty(this.SigInfo)
        [client,~,wasAdded]=Simulink.sdi.internal.Utils.getMatlabClient(this.SigInfo);
        if~wasAdded
            dlg=this.findDialog();
            currentTab=dlg.getActiveTab(this.TAB_CONTAINER_TAG);

            dlg.setActiveTab(this.TAB_CONTAINER_TAG,1)

            if~isfield(client.ObserverParams,'Enable')
                client.ObserverParams.Enable=true;
            end
            dlg.setWidgetValue('chkBoxEnable',client.ObserverParams.Enable);
            dlg.clearWidgetDirtyFlag('chkBoxEnable');

            this.dataAccessSettingCB(dlg);

            dlg.setWidgetValue('txtFcnCallback',client.ObserverParams.Function);
            dlg.clearWidgetDirtyFlag('txtFcnCallback')

            dlg.setWidgetValue('txtFcnParam',client.ObserverParams.Param);
            dlg.clearWidgetDirtyFlag('txtFcnParam')

            dlg.setWidgetValue('chkBoxTime',client.ObserverParams.IncludeTime);
            dlg.clearWidgetDirtyFlag('chkBoxTime')

            dlg.setActiveTab(this.TAB_CONTAINER_TAG,currentTab);
        end
    end
end
