




classdef ChartImage<handle

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

        function obj=ChartImage(chartPath,imageDir,imageFormat)
            obj.ImageDir=imageDir;
            obj.ImageFileName=char(matlab.lang.internal.uuid);
            obj.ImageFormat=imageFormat;
            obj.SystemPath=chartPath;
            obj.assertSystemPathIsValid();
            obj.captureImage();
        end

    end

    methods(Access=private)
        function captureImage(obj)
            sfprint(obj.SystemPath,obj.ImageFormat,obj.ImageFile,1);
        end

        function assertSystemPathIsValid(obj)
            get_param(obj.SystemPath,'name');
        end
    end
end
