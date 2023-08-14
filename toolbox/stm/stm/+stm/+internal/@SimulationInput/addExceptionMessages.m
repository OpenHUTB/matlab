
function addExceptionMessages(runcfg,me)
    [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
    runcfg.addMessages(tempErrors,tempErrorOrLog);
end