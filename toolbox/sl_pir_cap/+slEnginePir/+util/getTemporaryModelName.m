function[temporaryModelName]=getTemporaryModelName(prefix,modelName)




    temporaryKey='temporary';
    commonPrefixStartIndex=min(8,length(prefix))+1;
    temporaryPrefix=[temporaryKey,prefix(commonPrefixStartIndex:end)];
    temporaryModelName=slEnginePir.util.getBackupModelName(temporaryPrefix,modelName);
end

