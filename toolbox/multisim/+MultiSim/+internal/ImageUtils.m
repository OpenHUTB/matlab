classdef(Sealed,Abstract)ImageUtils<handle







    methods(Static)

        function[bytes,imageFormat]=getBytesFromImageFile(imagePath)
            [~,~,imageFormat]=fileparts(imagePath);
            imageFormat=strrep(imageFormat,'.','');



            fid=fopen(imagePath,'r');
            bytes=fread(fid,'uint8=>uint8');
            fclose(fid);
        end


        function imageString=getImageDataURIFromBytes(bytes,imageFormat)

            base64String=matlab.net.base64encode(bytes);
            imageString=sprintf('data:image/%s;base64,%s',...
            imageFormat,base64String);
        end


        function imageString=getImageDataURIFromFile(imagePath)
            import MultiSim.internal.ImageUtils.getBytesFromImageFile
            import MultiSim.internal.ImageUtils.getImageDataURIFromBytes

            [bytes,imageFormat]=getBytesFromImageFile(imagePath);
            imageString=getImageDataURIFromBytes(bytes,imageFormat);
        end

    end



end