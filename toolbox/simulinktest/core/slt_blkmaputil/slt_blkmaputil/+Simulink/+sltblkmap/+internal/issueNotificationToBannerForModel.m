function issueNotificationToBannerForModel(mdlH,isWarning,msgID,message)

    editors=SLM3I.SLDomain.getAllEditorsForBlockDiagram(mdlH);
    for idx=1:numel(editors)
        editor=editors(idx);
        activeMsgID=editor.getActiveNotification;
        if~isempty(activeMsgID)
            editor.closeNotificationByMsgID(activeMsgID);
        end
        if isWarning
            editor.deliverWarnNotification(msgID,message);
        else
            editor.deliverInfoNotification(msgID,message);
        end
    end
end

