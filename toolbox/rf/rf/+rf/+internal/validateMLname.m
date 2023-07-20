function validateMLname(newName,desc)



















    if~isvarname(newName)
        validateattributes(newName,{'char'},{'row'},'',desc)


        error(message('rf:shared:ValidateMLNameNotAVarName',desc,newName))
    end
