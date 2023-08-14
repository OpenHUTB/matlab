function out=getAllEntriesOfTypeInClosure(coderDict,type)




    slRoot=slroot;
    out=[];
    dict=coderDict;
    if strcmpi(coderDict.context,'model')
        dict=hex2num(coderDict.ID);
    end
    if slRoot.isValidSlObject(dict)
        dmType=type;
        if strcmp(type,'FunctionCustomizationTemplates')
            dmType='FunctionClasses';
        end
        scRefs=coderdictionary.data.SlCoderDataClient.getAllElementsOfCoderDataType(dict,dmType);

        for i=1:length(scRefs)
            out=[out,scRefs(i).getCoderDataEntry()];%#ok<AGROW>
        end

    else
        sType=coder.dictionary.internal.getSingleType(type);
        out=coder.internal.CoderDataStaticAPI.get(dict,sType);
    end
end


