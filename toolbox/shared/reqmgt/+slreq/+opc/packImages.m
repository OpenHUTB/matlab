

function packImages(images,package,reqSetName,saveOptions)




    if~isempty(images)
        cacheImages(package,images,reqSetName,saveOptions);
    end
end

function cacheImages(package,images,reqSetName,saveOptions)

    if nargin<4
        saveOptions=[];
    end


    availableImages=cell(0,1);
    packagePaths=cell(0,1);


    for i=1:length(images)
        cImage=images{i};
        imageObj=slreq.uri.SourcePath(cImage);
        imageObj.setReqSetName(reqSetName);
        imagePath=imageObj.getFullPath;





        if exist(imagePath,'file')==2
            availableImages{end+1}=imagePath;%#ok<AGROW>

            packagePath=imageObj.getPackagePath;
            packagePaths{end+1}=packagePath;%#ok<AGROW>
        end
    end

    package.addFiles(availableImages,packagePaths,saveOptions);

end
