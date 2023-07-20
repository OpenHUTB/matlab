



function fetchSelectedBlockSID(obj)

    ele=gsb(gcs,1);
    sid=Simulink.ID.getSID(ele);
    obj.setSelectedBlockSID(sid);

    msg.msgID='getSelectedBlockSIDs';
    msg.type='getSelectedBlockSIDs';
    msg.selectedBlockSID=obj.getSelectedBlockSID;
    message.publish(obj.getChannel,msg);
end