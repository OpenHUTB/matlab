function RefreshWidgets(this,dlg)



    dlg.setWidgetValue(this.LocalTag,this.CommLocal);
    dlg.setWidgetValue(this.SharedMemTag,this.UddUtil.EnumStr2Int('CoSimConnectionMethodEnum',this.CommSharedMemory));
    dlg.setWidgetValue(this.HostNameTag,this.CommHostName);
    dlg.setWidgetValue(this.PortNumberTag,this.CommPortNumber);
    dlg.setWidgetValue(this.BypassTag,this.CosimBypass);
    dlg.setWidgetValue(this.ShowInfoTag,this.CommShowInfo);


    [ens,vis]=this.GetEnablesAndVisibilities;

    dlg.setEnabled(this.LocalTag,ens.CommLocal);
    dlg.setEnabled(this.SharedMemTag,ens.CommSharedMemory);
    dlg.setEnabled(this.HostNameTag,ens.CommHostName);
    dlg.setEnabled(this.PortNumberTag,ens.CommPortNumber);
    dlg.setEnabled(this.BypassTag,ens.CosimBypass);
    dlg.setEnabled(this.ShowInfoTag,ens.CommShowInfo);

    dlg.setVisible(this.LocalTag,vis.CommLocal);
    dlg.setVisible(this.SharedMemTag,vis.CommSharedMemory);
    dlg.setVisible(this.HostNameTag,vis.CommHostName);
    dlg.setVisible(this.PortNumberTag,vis.CommPortNumber);
    dlg.setVisible(this.BypassTag,vis.CosimBypass);
    dlg.setVisible(this.ShowInfoTag,vis.CommShowInfo);

    dlg.setVisible(this.SharedMemTxtTag,vis.CommSharedMemoryTxt);
    dlg.setVisible(this.HostNameTxtTag,vis.CommHostNameTxt);
    dlg.setVisible(this.PortNumberTxtTag,vis.CommPortNumberTxt);

end

