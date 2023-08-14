function[preferredName,excludedStrings]=getUniqueFileName(preferredName,exts,excludedStrings)




    exts=unique(exts);
    generatedName=preferredName;
    while isFileExist(generatedName,exts)
        excludedStrings{end+1}=generatedName;%#ok<AGROW>
        generatedName=matlab.lang.makeUniqueStrings(...
        preferredName,excludedStrings);
    end
    preferredName=generatedName;
end

function tf=isFileExist(name,exts)
    tf=false;
    for idx=1:numel(exts)
        resolvedResult=Simulink.loadsave.resolveFile(name,exts{idx});
        if~isempty(resolvedResult)
            tf=true;
            return;
        end
    end
end
