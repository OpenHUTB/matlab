classdef FileImageSource<matlab.graphics.shape.internal.image.ImageSource




    properties
        FileName(1,1)string
    end

    methods
        function obj=FileImageSource(filename)
            obj.FileName=string(filename);
        end

        function im=loadImage(obj)

            [im,~,alpha]=imread(char(obj.FileName));
            if~isempty(alpha)
                im=cat(3,im,alpha);
            end
        end
    end
end