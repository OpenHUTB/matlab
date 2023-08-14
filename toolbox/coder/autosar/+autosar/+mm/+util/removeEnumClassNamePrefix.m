function[enumLiteralNames,isRemoved]=removeEnumClassNamePrefix(enumClassNamePrefix,actEnumLiteralNames)




    canRemoveClassName=all(strncmp(actEnumLiteralNames,enumClassNamePrefix,length(enumClassNamePrefix)));

    if canRemoveClassName

        enumLiteralNames=regexprep(actEnumLiteralNames,['^',enumClassNamePrefix],'');


        validIdentifiers=all(cellfun(@isvarname,cellstr(enumLiteralNames)));

        if~validIdentifiers
            enumLiteralNames=actEnumLiteralNames;
            isRemoved=false;
        else
            isRemoved=true;
        end
    else
        enumLiteralNames=actEnumLiteralNames;
        isRemoved=false;
    end
