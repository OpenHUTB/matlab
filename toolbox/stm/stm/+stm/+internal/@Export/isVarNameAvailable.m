

function[nameIsAvailable,invalidNameError]=isVarNameAvailable(varName,forceOverwrite)
    nameIsAvailable=true;
    invalidNameError=false;

    if forceOverwrite
        return;
    end

    if~isvarname(varName)

        nameIsAvailable=false;
        invalidNameError=true;
    else
        nameIsAvailable=~evalin('base',['exist(''',varName,''', ''var'')']');
    end
end
