function unpackProxyOptions(package,reqSetName)





    MAT_PART='IMPORT';

    md5ReqSetName=slreq.utils.getMD5hash(reqSetName);


    matFileRenames=containers.Map('KeyType','char','ValueType','char');


    fileList=package.getFileList();


    for i=1:length(fileList)
        aFile=fileList{i};


        tokens=strsplit(aFile,'/');




        if length(tokens)<2
            continue;
        end

        if~strcmp(tokens{2},MAT_PART)
            continue;
        end


        if length(tokens)==3
            matFileName=tokens{3};



            matTokens=strsplit(matFileName,'_');
            if length(matTokens)==2
                oldReqSetName=matTokens{1};


                if~strcmp(oldReqSetName,md5ReqSetName)
                    newName=['/',MAT_PART,'/',md5ReqSetName,'_',matTokens{2}];
                    matFileRenames(aFile)=newName;
                else

                    matFileRenames(aFile)=aFile;
                end
            end
        end
    end




    usrTempDir=fullfile(tempdir,'RMI');
    importOptionsDir=fullfile(usrTempDir,'IMPORT');
    if exist(importOptionsDir,'dir')~=7
        mkdir(importOptionsDir);
    end



    matFiles=keys(matFileRenames);
    for i=1:length(matFiles)
        srcMatFile=matFiles{i};

        destMatFile=matFileRenames(srcMatFile);

        destFile=fullfile(usrTempDir,destMatFile);

        if ispc
            destFile=strrep(destFile,filesep,'/');
        end

        package.copyFile(srcMatFile,destFile);



    end
end
