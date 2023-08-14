

function bool=isModel(name)
    bool=stm.internal.Coverage.getStatus(name)==stm.internal.Coverage.MODEL;
end
