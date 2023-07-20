function errors=setPropertyValue(elemUuid,srcHdlOrName,propObj,changeSet,options,context)


    elementWrapper=systemcomposer.internal.propertyInspector.wrappers.ElementWrapper.getWrapperFromUUID(elemUuid,srcHdlOrName,options,context);


    setterFunc=propObj.setter;
    if~strcmp(setterFunc,"")
        eval(['callBackFunction = ',setterFunc,';'])
        errors=callBackFunction(elementWrapper,changeSet,propObj);
    end
end

