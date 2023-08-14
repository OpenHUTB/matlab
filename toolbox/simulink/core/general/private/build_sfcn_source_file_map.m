function sourceFileMap=build_sfcn_source_file_map(buildInfo)




    sourceFileMap=containers.Map('KeyType','char','ValueType','any');
    sourceFiles=buildInfo.getSourceFiles(true,true,{'Sfcn'});
    for i=1:length(sourceFiles)
        sourceFile=sourceFiles{i};

        [~,basename]=fileparts(sourceFile);
        if(~sourceFileMap.isKey(basename))
            sourceFileMap(basename)={};
        end

        sourceFileMap(basename)=[sourceFileMap(basename),sourceFile];
    end
end