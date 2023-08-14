function removeNotificationBannerInModel(mdlH,msgID)

    editors=SLM3I.SLDomain.getAllEditorsForBlockDiagram(mdlH);
    for idx=1:numel(editors)
        editor=editors(idx);
        activeMsgID=editor.getActiveNotification;
        if strcmp(activeMsgID,msgID)
            editor.closeNotificationByMsgID(activeMsgID);
        end
    end
end

