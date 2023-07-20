function[imageExists,imageExt,imageFile]=ne_imagefilefromsourcefile(sourceFile)




    persistent IMAGE_EXTENSIONS;
    if isempty(IMAGE_EXTENSIONS)
        IMAGE_EXTENSIONS={...
        '.svg',...
        '.jpg',...
        '.bmp',...
'.png'...
        };
    end

    [directory,basename]=fileparts(sourceFile);

    for i=1:numel(IMAGE_EXTENSIONS)
        ext=IMAGE_EXTENSIONS{i};

        imageFileToCheck=fullfile(directory,[basename,ext]);


        dirResult=dir(imageFileToCheck);
        if numel({dirResult.isdir})==1
            imageExists=true;
            imageExt=ext;
            imageFile=imageFileToCheck;
            return;
        end
    end


    imageExists=false;
    imageExt='';
    imageFile='';

end
