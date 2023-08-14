function newSearchDirectories=extractRelevantDirs(rootDirectory,searchDirectories,customCodeString)



    [s,e]=regexp(customCodeString,'#include\s*\"[^\"\n]+\"');

    includedFiles={};
    for i=1:length(s)
        includeStr=customCodeString(s(i):e(i));
        [s1,e1]=regexp(includeStr,'\"[^\"]+\"','once');
        fileName=includeStr(s1+1:e1-1);
        [includedFile,errorStr]=CGXE.Utils.tokenize(rootDirectory,fileName,'include file',searchDirectories);
        if(isempty(errorStr))
            includedFiles{end+1}=includedFile{1};
        end
    end

    newSearchDirectories=cell(1,length(includedFiles));
    for i=1:length(includedFiles)
        newSearchDirectories{i}=CGXE.Utils.stripPathFromName(includedFiles{i});
    end
    newSearchDirectories=CGXE.Utils.orderedUniquePaths(newSearchDirectories);
