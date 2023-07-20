classdef(Sealed,Abstract)ImageUtils<handle





    properties(Constant)
        SupportedImageFormats={'jpg','png'};
    end

    methods(Static)
        function bytes=getBytesFromCDataRGB(cdata,imageFormat,imageQuality)
            validateattributes(imageQuality,{'double'},{'scalar','real','>',0,'<=',1.0});
            imageFormat=validatestring(imageFormat,mls.internal.ImageUtils.SupportedImageFormats);

            tmpDir=fullfile(tempdir,'.imageutils');
            [~,~,~]=mkdir(tmpDir);


            tmpFile=fullfile([tempname(tmpDir),'.',imageFormat]);


            if(strcmp(imageFormat,"jpg"))
                imwrite(cdata,tmpFile,'Quality',round(imageQuality*100));
            else
                imwrite(cdata,tmpFile);
            end


            deleteFile=onCleanup(@()delete(tmpFile));

            bytes=mls.internal.ImageUtils.getBytesFromImageFile(tmpFile)';
        end
    end

    methods(Static,Access=private)
        function[bytes,imageFormat]=getBytesFromImageFile(imagePath)
            [~,~,imageFormat]=fileparts(imagePath);
            imageFormat=strrep(imageFormat,'.','');



            fid=fopen(imagePath,'r');
            bytes=fread(fid,'uint8=>uint8');
            fclose(fid);
        end
    end
end
