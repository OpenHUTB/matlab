function[status]=postApply(obj)






    status=true;


    if~isempty(obj.selectedFolders)
        selectedFoldersDelimited=obj.covertFolderStrToDelimitedChar();
        if~isempty(obj.cloneUIObj.m2mObj)
            obj.cloneUIObj.isAcrossModel=true;
            obj.cloneUIObj.listOfFolders=selectedFoldersDelimited;
        end
    end

end
