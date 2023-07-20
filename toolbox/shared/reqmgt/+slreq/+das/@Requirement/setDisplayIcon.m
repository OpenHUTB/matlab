function setDisplayIcon(this,sourceChangeDetected)




    if nargin<2
        sourceChangeDetected=false;
    end

    iconRegistry=slreq.gui.IconRegistry.instance;

    if this.dataModelObj.external
        if this.dataModelObj.isImportRootItem
            if this.dataModelObj.getPendingUpdateStatus()==slreq.dataexchange.UpdateDetectionStatus.Detected
                icon=iconRegistry.importNode_warning;
            else
                icon=iconRegistry.importNode;
            end
        elseif this.dataModelObj.locked
            icon=iconRegistry.externalReq;
        elseif sourceChangeDetected
            icon=iconRegistry.externalReqWithChangeIssue;
        else
            icon=iconRegistry.externalReqUnlocked;
        end
    elseif this.dataModelObj.isJustification




        icon=iconRegistry.justification;
    else
        if sourceChangeDetected
            icon=iconRegistry.mwReqWithChangeIssue;
        else
            icon=iconRegistry.mwReq;
        end
    end
    this.iconPath=icon;
end
