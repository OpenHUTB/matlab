function setScopeParameter(obj,propertyName,value)




    if isLaunched(obj.Scope)
        setScopeParam(obj.Scope,'Visuals',obj.VisualName,propertyName,value);
    else
        if ischar(value)
            datatype='string';
        elseif iscell(value)
            datatype='cell';
        elseif isstruct(value)
            datatype='struct';
        else
            datatype='bool';
        end
        setScopeParamOnConfig(obj.Scope,'Visuals',obj.VisualName,propertyName,datatype,value);
    end
end