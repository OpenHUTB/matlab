function imageSize=nesl_imagesize(imageFile)






    [fileDir,fileBase,fileExt]=fileparts(imageFile);

    if strcmp(fileExt,'.svg')




        getSize=str2func('MG2.SvgIO.defaultSize');
        imageSize=getSize(imageFile);
        imageSize=[imageSize(2),imageSize(1)];
    else
        img=imread(imageFile);
        imageSize=[size(img,1),size(img,2)];
    end

end
