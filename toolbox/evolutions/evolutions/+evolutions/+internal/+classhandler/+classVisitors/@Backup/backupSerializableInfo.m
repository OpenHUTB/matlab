function backupSerializableInfo(info)




    if info.Dirty&&isfile(info.XmlFile)

        backupArtifact(info);



        info.Dirty=false;
    end
end

function backupArtifact(curAi)
    backupXmlFile=sprintf("%s%s",curAi.XmlFile,".bak");
    try

        copyfile(curAi.XmlFile,backupXmlFile);

        xmlFile=evolutions.internal.utils.getRelativePathFromProject(curAi,curAi.XmlFile);
        backupXmlFile=evolutions.internal.utils.getRelativePathFromProject(curAi,backupXmlFile);
        evolutions.internal.BackupReader.addBackupFile(xmlFile,backupXmlFile);
    catch ME

        exception=MException...
        ('evolution:manage:BackupFail',getString(message...
        ('evolutions:manage:BackupFail')));
        exception=exception.addCause(ME);
        throw(exception);
    end
end


