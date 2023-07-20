classdef SourcePathType
    enumeration
        FullPath;
        PackagePath;
        ResourcePath;
    end

    methods
        function tf=isFullPath(this)
            tf=slreq.uri.SourcePathType.FullPath==this;
        end

        function tf=isPackagePath(this)
            tf=slreq.uri.SourcePathType.PackagePath==this;
        end

        function tf=isResourcePath(this)
            tf=slreq.uri.SourcePathType.ResourcePath==this;
        end

    end
end