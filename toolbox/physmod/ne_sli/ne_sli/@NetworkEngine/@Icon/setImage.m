function setImage(this,sourceFile,permuteImage,imgExt)




    fileToPackage=ne_private('ne_filetopackagefunction');

    [fileDir,fileBase,srcExt]=fileparts(sourceFile);
    imgFile=fullfile(fileDir,[fileBase,imgExt]);
    pm_assert(exist(imgFile,'file'),...
    'cannot file image file ''%s''',imgFile);






    sourceFileExists=exist(sourceFile,'file');
    if sourceFileExists
        fileString=fileToPackage(sourceFile);
        pm_assert(~isempty(fileString),...
        'Can not convert file ''%s'' to feval string',sourceFile);
    else
        sourceFile=strrep(sourceFile,srcExt,imgExt);
        [~,fileString]=fileToPackage(sourceFile);
        packageNameFromDirectoryPath=ne_private('ne_packagenamefromdirectorypath');
        [~,srcExt]=packageNameFromDirectoryPath(sourceFile);
    end

    maskStr=sprintf('image(nesl_icon(gcb, ''%s'', ''%s'', ''%s'', %d, %d))',...
    fileString,srcExt,imgExt,permuteImage,sourceFileExists);



    imageSize=nesl_private('nesl_imagesize');
    iconSize=imageSize(imgFile);

    this.Display=sprintf('%s',maskStr);



    this.Size=[iconSize(2),iconSize(1)];
    if permuteImage
        this.Size=[iconSize(1),iconSize(2)];
    end

    this.ShowFrame=false;
    this.ShowName=true;
    this.RequiredFiles={imgFile};

end
