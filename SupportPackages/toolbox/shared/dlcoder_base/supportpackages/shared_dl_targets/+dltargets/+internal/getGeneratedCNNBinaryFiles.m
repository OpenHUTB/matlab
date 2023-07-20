function generatedCNNBinaryFiles=getGeneratedCNNBinaryFiles(bldDirectory)




    dirlist=[dir(fullfile(bldDirectory,'*.bin'))];
    allFiles={dirlist(:).name};
    allFiles=unique(allFiles);


    indices=~cellfun(@isSourceFile,allFiles);
    generatedCNNBinaryFiles=allFiles(indices);

    function logicalResult=isSourceFile(filename)
        [~,~,extension]=fileparts(filename);
        [startIndex,~]=regexp(extension,'(?:\.cpp|\.hpp|\.cu|\.c|\.h|\.o)$');

        logicalResult=~isempty(startIndex);
    end
end


