function OnWidgetChangeCB(this,tag,dlg,value)
    if strcmp(tag,'HdlComm.CosimBypass')
        this.CosimBypass=value;
    end

    switch(tag)
    case this.LocalTag
        this.CommLocal=value;
        if value==true
            this.CommHostName=this.localHostName;
        else
            this.CommHostName=this.lastRemoteHostName;
            this.CommSharedMemory='Socket';
        end
    case this.HostNameTag
        if(this.CommLocal==false)
            this.lastRemoteHostName=value;
        end
    end
    this.RefreshWidgets(dlg);
end
