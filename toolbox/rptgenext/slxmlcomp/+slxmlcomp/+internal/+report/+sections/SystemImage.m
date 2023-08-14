




classdef SystemImage<handle

    properties(Access=private)
        ImageDir;
        ImageFormat;
        SystemPath;
        ImageFileName;
    end

    properties(GetAccess=public,SetAccess=private,Dependent)
        ImageFile;
    end

    methods
        function file=get.ImageFile(obj)
            file=fullfile(obj.ImageDir,[obj.ImageFileName,'.',obj.ImageFormat]);
        end
    end

    methods(Access=public)

        function obj=SystemImage(systemPath,imageDir,imageFormat)
            obj.ImageDir=imageDir;
            obj.ImageFileName=char(matlab.lang.internal.uuid);
            obj.ImageFormat=imageFormat;
            obj.SystemPath=systemPath;
            obj.captureImage();
        end

    end

    methods(Access=private)
        function captureImage(obj)
            print(['-s',obj.SystemPath],['-d',obj.ImageFormat],obj.ImageFile);
        end
    end
end
