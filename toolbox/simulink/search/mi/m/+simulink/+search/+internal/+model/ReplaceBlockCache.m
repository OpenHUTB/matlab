







classdef ReplaceBlockCache<handle

    methods(Access=public)
        function obj=ReplaceBlockCache(handle,blockName,blockParentPath,type,subtype)
            obj.handle=handle;
            obj.name=blockName;
            obj.parent=blockParentPath;
            obj.type=type;
            obj.subtype=subtype;
        end
    end

    properties(Access=public)


        handle=[];
        name=[];
        parent=[];
        type=[];
        subtype=[];
    end
end
