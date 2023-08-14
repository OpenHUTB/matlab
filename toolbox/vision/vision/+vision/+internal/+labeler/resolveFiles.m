
function[fileList,unresolvedFiles]=resolveFiles(fileList,validAltPaths)



    unresolvedFiles={};

    numFiles=numel(fileList);


    for idx=1:numFiles
        file=fileList{idx};

        if~isempty(file)


            bestMatchValue=0;
            bestMatchIdx=0;

            for vAltPathNum=1:numel(validAltPaths)
                oldPath=validAltPaths{vAltPathNum}{1};
                if startsWith(file,oldPath)
                    if numel(oldPath)>bestMatchValue
                        bestMatchValue=numel(oldPath);
                        bestMatchIdx=vAltPathNum;
                    end
                end
            end

            if bestMatchIdx>0

                oldPath=validAltPaths{bestMatchIdx}{1};

                for altPathNum=2:numel(validAltPaths{bestMatchIdx})


                    altPath=validAltPaths{bestMatchIdx}{altPathNum};
                    tempPath=strrep(file,oldPath,altPath);
                    newTempPath=regexprep(tempPath,'[\\/]',filesep);




                    if exist(newTempPath,'file')
                        fileList{idx}=newTempPath;
                    else
                        if~exist(fileList{idx},'file')
                            unresolvedFiles{end+1}=fileList{idx};%#ok<AGROW>
                        end
                    end
                end
            else
                if~exist(fileList{idx},'file')
                    unresolvedFiles{end+1}=fileList{idx};%#ok<AGROW>
                end
            end
        end
    end
end