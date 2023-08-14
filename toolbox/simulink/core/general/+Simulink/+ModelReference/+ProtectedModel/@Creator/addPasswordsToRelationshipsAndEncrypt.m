function addPasswordsToRelationshipsAndEncrypt(obj)




    for i=1:length(obj.relationshipClasses)
        currentRelationship=obj.relationshipClasses{i};
        currentEncryptionCategory=currentRelationship.getEncryptionCategory();
        currentPW=Simulink.ModelReference.ProtectedModel.PasswordManager.getPasswordForEncryptionCategory(...
        obj.ModelName,currentEncryptionCategory);
        if~isempty(currentPW)&&(obj.Encrypt||currentEncryptionCategory=="MODIFY")
            currentRelationship.isEncrypted=true;
            fileList=currentRelationship.getFileList();



            categoryList=currentRelationship.getCategoryList();

            if obj.supportsCodeGen
                rootDir=Simulink.ModelReference.ProtectedModel.getRTWBuildDir();
            else
                rootDir=Simulink.ModelReference.ProtectedModel.getSimBuildDir();
            end

            for j=1:length(fileList)
                currentPart=fileList{j};
                if length(categoryList)<j||isempty(categoryList{j})
                    currentCategory='build';
                else
                    currentCategory=categoryList{j};
                end


                obj.copyFile(currentPart,currentCategory,rootDir);
            end
        end
    end


    for i=1:length(obj.relationshipClasses)
        currentRelationship=obj.relationshipClasses{i};
        if currentRelationship.isEncrypted
            cat=currentRelationship.getEncryptionCategory();
            switch cat
            case 'SIM'
                obj.isSimEncrypted=true;
            case 'RTW'
                obj.isRTWEncrypted=true;
            case 'VIEW'
                obj.isViewEncrypted=true;
            case 'HDL'
                obj.isHDLEncrypted=true;
            case 'MODIFY'
                obj.isModifyEncrypted=true;
            end
        end
    end






    for i=1:length(obj.relationshipClasses)
        currentRelationship=obj.relationshipClasses{i};
        cat=currentRelationship.getEncryptionCategory();
        switch cat
        case 'SIM'
            assert(obj.isSimEncrypted==currentRelationship.isEncrypted);
        case 'RTW'
            assert(obj.isRTWEncrypted==currentRelationship.isEncrypted);
        case 'VIEW'
            assert(obj.isViewEncrypted==currentRelationship.isEncrypted);
        case 'HDL'
            assert(obj.isHDLEncrypted==currentRelationship.isEncrypted);
        case 'MODIFY'
            assert(obj.isModifyEncrypted==currentRelationship.isEncrypted);
        end
    end


    load('extraInformation.mat','gi');
    gi.isSimEncrypted=obj.isSimEncrypted;
    gi.isRTWEncrypted=obj.isRTWEncrypted;
    gi.isViewEncrypted=obj.isViewEncrypted;
    gi.isHDLEncrypted=obj.isHDLEncrypted;


    gi.isModifyEncrypted=obj.isModifyEncrypted;
    save('extraInformation.mat','gi');
end


