function messageOut=prepareMessage(messageIn,data)





    data=evolutions.internal.utils.makeCell(data);
    messageOut=evolutions.internal.ui.tools.makeStringFromCell(data);
    messageOut=sprintf('%s\n%s',messageIn,messageOut);
end
