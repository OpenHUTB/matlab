function init(obj)


    obj.subscribe=message.subscribe(['/',obj.channel],@obj.sendData);

