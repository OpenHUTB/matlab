


function newvalue=getEnableDataOwnership(obj,val)

    if isequal(obj.ModuleNamingRule,'SameAsModel')
        newvalue='on';
    else
        newvalue='off';
    end
