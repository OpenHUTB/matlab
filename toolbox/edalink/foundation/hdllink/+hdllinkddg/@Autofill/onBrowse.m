function onBrowse(this,dialog)


    if(this.EnableBrowser)
        this.EnableBrowser=0;
        dialog.setVisible('edaHierarchy',false);
    else
        cInfo=this.Parent.CommSource.GetConnInfo;
        this.TreeItems=autopopulate(...
        '%^hierarchy^%',...
        double(cInfo.isOnLocalHost),...
        double(cInfo.isShared),...
        cInfo.hostName,...
        cInfo.portNumber);
        this.EnableBrowser=1;
        dialog.setVisible('edaHierarchy',true);
    end
    dialog.resetSize;
end

