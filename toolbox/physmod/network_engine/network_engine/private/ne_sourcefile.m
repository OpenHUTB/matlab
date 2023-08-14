function[sourceFile,isText]=ne_sourcefile(sourceFile)







    textFileExt={'.ssc','.m'};

    [fileDir,fileBase]=fileparts(sourceFile);

    isText=false;
    for idx=1:numel(textFileExt)
        textFile=fullfile(fileDir,[fileBase,textFileExt{idx}]);
        if exist(textFile,'file')
            isText=true;
            sourceFile=textFile;
            break;
        end
    end

end
