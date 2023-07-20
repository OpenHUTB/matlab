function out=encryptForHash(file,iv,modelName,relationship)





    category=Simulink.ModelReference.ProtectedModel.getEncryptionCategoryForRelationship(modelName,relationship);
    password=Simulink.ModelReference.ProtectedModel.PasswordManager.getPasswordForEncryptionCategory(...
    modelName,category);
    destFile=tempname;
    copyfile(file,destFile,'f');
    cleanupVar=onCleanup(@()locTryDeletingFile(destFile));



    [~,out]=Simulink.ModelReference.ProtectedModel.encrypt('AES',destFile,true,password,iv);

end

function locTryDeletingFile(destFile)

    try
        delete(destFile);
    catch
    end

end