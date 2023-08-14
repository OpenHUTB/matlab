classdef Format




    enumeration
        PNG,
        JPEG,
        JPG,
        BMP,
        SVG,
        EMF,
        PDF,
TIFF
    end

    methods
        function fExt=fileExtension(this)
            fExt=string.empty();
            switch(this)
            case "PNG"
                fExt=".png";
            case{"JPG","JPEG"}
                fExt=".jpg";
            case "BMP"
                fExt=".bmp";
            case "SVG"
                fExt=".svg";
            case "EMF"
                fExt=".emf";
            case "PDF"
                fExt=".pdf";
            case "TIFF"
                fExt=".tiff";
            end
        end
    end
end