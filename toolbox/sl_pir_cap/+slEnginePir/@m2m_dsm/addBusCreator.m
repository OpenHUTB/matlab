function addBusCreator(this,newFullPath,numIn,dataTypeStr)





    bH=add_block('simulink/Signal Routing/Bus Creator',newFullPath);
    set_param(bH,'Inputs',numIn);

    set_param(bH,'outdatatypestr',dataTypeStr);
    set_param(bH,'InheritFromInputs','off');
    set_param(bH,'NonVirtualBus','on');
end
