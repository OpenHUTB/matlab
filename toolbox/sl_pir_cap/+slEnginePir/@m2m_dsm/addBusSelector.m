function addBusSelector(this,newFullPath,elementName)



    bH=add_block('simulink/Signal Routing/Bus Selector',newFullPath);

    dotPos=find(elementName=='.');
    elementName=elementName(dotPos(1)+1:end);

    set_param(bH,'OutputSignals',elementName);

end