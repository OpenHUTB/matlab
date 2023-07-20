function icon=nesl_geticon(sourceFile,permuteImage)




    getImage=ne_private('ne_imagefilefromsourcefile');

    [imageExists,imageExt]=getImage(sourceFile);

    icon=NetworkEngine.Icon;

    if nargin==1
        permuteImage=false;
    end

    if imageExists
        icon.setImage(sourceFile,permuteImage,imageExt);
    end

end
