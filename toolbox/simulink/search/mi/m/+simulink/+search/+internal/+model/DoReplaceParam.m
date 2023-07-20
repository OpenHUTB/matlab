

classdef DoReplaceParam<handle
    properties(Access=public)
        blkUri=0.0;
        propName='';
        originalValue=[];
        newValue=[];
        currentValue=[];
        errMsg='';
    end

    methods
        function obj=DoReplaceParam()
            obj.blkUri=0.0;
            obj.propName='';
            obj.originalValue=[];
            obj.newValue=[];
            obj.currentValue=[];
            obj.errMsg='';
        end
    end
end
