function deleteSerializableInfoBackup(info)




    [xmlFilePath,xmlFileName]=fileparts(info.XmlFile);
    backupXmlFile=fullfile(xmlFilePath,strcat(xmlFileName,'.xml','.bak'));
    if isfile(backupXmlFile)
        delete(backupXmlFile);
    end
end


