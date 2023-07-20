


function newvalue=setEnableDataOwnership(obj,value)

    if isequal(value,'on')
        obj.ModuleNamingRule='SameAsModel';
    else
        obj.ModuleNamingRule='Unspecified';
    end
    newvalue=value;
