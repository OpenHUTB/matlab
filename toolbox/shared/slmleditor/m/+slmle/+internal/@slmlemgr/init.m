function init(obj)



    obj.msgId=message.subscribe(obj.channel,@obj.action);
    obj.MLFBEditorMap=containers.Map('KeyType','int32','ValueType','any');






