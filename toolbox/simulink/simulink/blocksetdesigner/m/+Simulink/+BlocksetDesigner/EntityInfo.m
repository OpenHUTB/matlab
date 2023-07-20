classdef EntityInfo<handle
    properties(Access=public,Hidden=true)

Id
ParentId
Type
IsLeafNode
IsSupported
    end

    methods
        function obj=EntityInfo(type,parentId)
            obj.Id=[type,'_',char(matlab.lang.internal.uuid)];
            obj.ParentId=parentId;
            obj.Type=type;
            obj.IsLeafNode=0;
            obj.IsSupported=1;
        end
    end
end