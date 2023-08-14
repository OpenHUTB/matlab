function validateMLname(newName,desc)






















    if~isvarname(newName)
        validateattributes(newName,{'char'},{'row'},'',desc)
        error(message('serdes:serdesdesigner:ValidateMLNameNotAVarName',desc,newName))
    end