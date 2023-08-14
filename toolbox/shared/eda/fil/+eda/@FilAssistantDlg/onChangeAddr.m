function onChangeAddr(this,dlg,tag,value)




    try
        switch tag
        case 'edaIpAddrEdt'
            this.BuildInfo.IPAddress=value;
        case 'edaMacAddrEdt'
            this.BuildInfo.MACAddress=value;
        end

        if this.IsInHDLWA

            taskObj=Advisor.Utils.convertMCOS(dlg.getSource);
            hdlwa.setOptionsCallBack(taskObj);
        end

    catch ME
        switch tag
        case 'edaIpAddrEdt'
            dlg.setWidgetValue(tag,this.BuildInfo.IPAddress);
        case 'edaMacAddrEdt'
            dlg.setWidgetValue(tag,this.BuildInfo.MACAddress);
        end
        rethrow(ME);
    end

