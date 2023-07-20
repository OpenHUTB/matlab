function notifySfcnBuilderGUI(channel,messageContent,actionType)
    msg.content=messageContent;
    msg.command=actionType;
    message.publish(channel,msg);
end