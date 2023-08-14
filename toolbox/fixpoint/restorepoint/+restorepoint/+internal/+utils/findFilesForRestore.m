function[filesToRestore,filesThatCannotBeRestored]=...
    findFilesForRestore(restoreData)





    allDependencies=restoreData.getOriginalFiles;
    filesToRestore={};
    filesThatCannotBeRestored={};
    for depIdx=1:length(allDependencies)
        curDep=allDependencies{depIdx};


        if~isempty(dir(curDep))
            [needsRestore,reason]=elementNeedsRestore(curDep,restoreData);
            if needsRestore
                if canRestoreFile(curDep)
                    filesToRestore{end+1}={curDep,reason};%#ok<AGROW>
                else
                    filesThatCannotBeRestored{end+1}=curDep;%#ok<AGROW>
                end
            end
        else

            filesToRestore{end+1}={curDep,'FileChanged'};%#ok<AGROW>

            dirIsWriteable=restorepoint.internal.utils.dirIsWritable(curDep);
            if~dirIsWriteable
                filesThatCannotBeRestored{end+1}=curDep;%#ok<AGROW>  
            end
        end
    end
end

function[needsRestore,reason]=elementNeedsRestore(currentFullFile,restoreData)
    reason='';
    needsRestore=false;
    if fileHasExpiredChecksum(currentFullFile,restoreData)
        needsRestore=true;
        reason='FileChanged';
        return;
    end
end

function isExpired=fileHasExpiredChecksum(currentFullFile,restoreData)
    isExpired=false;
    s=restoreData.getDataForFile(currentFullFile);
    if isempty(s)









        return;
    end

    curCheckSum=Simulink.getFileChecksum(currentFullFile);
    if~strcmp(s.checkSum,curCheckSum)
        isExpired=true;
    end
end

function canRestore=canRestoreFile(currentFullFile)

    fileIsWriteable=restorepoint.internal.utils.fileIsWritable(currentFullFile);
    dirIsWriteable=restorepoint.internal.utils.dirIsWritable(currentFullFile);
    canRestore=(fileIsWriteable&&dirIsWriteable);

end



