function saveFlag=saveAction(obj,str)






    switch str
    case 'saveitem'
        saveFlag=saveFile(obj);
    case 'saveasitem'

        matFilePath=getMatFilePath(obj);
        if isequal(matFilePath,0)
            saveFlag=false;
            return;
        end
        saveFlag=saveFile(obj,matFilePath);
    end

end

