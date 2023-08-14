function updateCompilerOpts(hObj)




    if hObj.isPILProject


        if isempty(strfind(getProp(hObj,'compilerOptionsStr'),'-g'))
            setProp(hObj,'compilerOptionsStr',[getProp(hObj,'compilerOptionsStr'),' -g']);
        end

    end
