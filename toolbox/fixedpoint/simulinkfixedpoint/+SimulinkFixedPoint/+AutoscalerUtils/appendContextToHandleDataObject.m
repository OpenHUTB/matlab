function dataObject=appendContextToHandleDataObject(dataObject,context)











    propertyName='fxptautoscale_contextModel';
    noContextModelProperty=isempty(dataObject.findprop(propertyName));
    if noContextModelProperty
        h=dataObject.addprop(propertyName);
        h.Hidden=true;
        h.Transient=true;
    end


    modelObject=get_param(bdroot(context.Handle),'Object');


    dataObject.fxptautoscale_contextModel=modelObject;
end


