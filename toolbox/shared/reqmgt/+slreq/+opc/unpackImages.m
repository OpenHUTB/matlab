function images=unpackImages(package,loadOptions)






    if isempty(loadOptions)
        fileList=package.getFileList();
    else
        fileList=loadOptions.readerHandle.getMatchingPartNames("/slrequirements/");
    end

    images={};











    for i=1:length(fileList)
        afile=fileList{i};



        if contains(afile,'.xml')||contains(afile,'.mat')
            continue;
        end

        images{end+1}=afile;%#ok<AGROW>
    end




    images=copyImages(package,images,loadOptions);
end

function imagesForPacking=copyImages(package,images,loadOptions)


    destFiles=cell(1,length(images));
    [~,reqSetName]=fileparts(package.filepath);


    imagesForPacking=cell(size(images));
    for i=1:length(images)









        image=images{i};
        if startsWith(image,'/slrequirements')


            image=image(16:end);
        end
        imagePathObj=slreq.uri.SourcePath(image);

        imagePathObj.setReqSetName(reqSetName);

        if~startsWith(image,imagePathObj.PACKAGE_HASHSET_PREFIX)





            imagePathObj.setResourceMacro(imagePathObj.RESOURCE);
            imagePathObj.setPathType('PackagePath');
        end


        destFile=imagePathObj.getFullPath;
        imagesForPacking{i}=imagePathObj.getResourcePath;

        if exist(destFile,'file')~=2
            parentDir=fileparts(destFile);
            if exist(parentDir,'dir')~=7
                mkdir(parentDir);
            end
        end

        destFiles{i}=destFile;
    end

    package.copyFiles(images,destFiles,loadOptions);
end
