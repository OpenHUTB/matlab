function newPath=incrementFilePath(inPath)






    newPath=inPath;
    [outputPath,outputName,outputExt]=fileparts(inPath);


    fileExistsInPathFlag=isfile(inPath)||(isfolder([outputPath,outputName]));
    if fileExistsInPathFlag
        increment=1;
        while(fileExistsInPathFlag)


            tmpFileName=sprintf('%s_%d',outputName,increment);
            tmpPath=fullfile(outputPath,[tmpFileName,outputExt]);
            if~isfile(tmpPath)
                newPath=tmpPath;
                fileExistsInPathFlag=0;
            end
            increment=increment+1;
        end
    end
end
