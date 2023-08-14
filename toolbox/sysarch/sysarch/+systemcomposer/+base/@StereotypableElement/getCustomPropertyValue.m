function value=getCustomPropertyValue(this,propObj)




    value=eval(systemcomposer.internal.arch.getPropertyValue(this,propObj.propertySet.getName,propObj.getName));
    if iscell(value)
        value=string(value);
    end
end