function commonParent=getCommonParentFolder(fileList)






    if isempty(fileList)
        commonParent="";
        return
    end

    commonParent=fileparts(fileList(1));

    if isscalar(fileList)
        return
    end

    grandParent=fileparts(commonParent);

    for index=2:numel(fileList)
        file=fileList(index);
        while~i_isParent(commonParent,file)...
            &&~strcmp(commonParent,grandParent)
            commonParent=grandParent;
            grandParent=fileparts(grandParent);
        end
        if~i_isParent(commonParent,file)
            commonParent="";
            return
        end
    end

end


function result=i_isParent(possibleParent,possibleChild)
    if~endsWith(possibleParent,filesep)
        possibleParent=strcat(possibleParent,filesep);
    end
    result=possibleChild.startsWith(possibleParent);
end