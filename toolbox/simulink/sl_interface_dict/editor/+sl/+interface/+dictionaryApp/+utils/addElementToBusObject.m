function busObj=addElementToBusObject(busObj,elementName,position)




    elementObj=Simulink.BusElement();
    elementObj.Name=elementName;

    busObj.Elements=[busObj.Elements(1:position-1);...
    elementObj;busObj.Elements(position:end)];
end


