

classdef ReplaceProcessor<handle
    properties(Access=protected)
        m_replaceParam=[];
        m_blockCache=[];
        m_replaceData=[];
    end

    methods(Access=public)
        function obj=ReplaceProcessor()
            obj.m_replaceParam=[];
            obj.m_blockCache=[];
            obj.m_replaceData=[];
        end
    end

    methods(Abstract,Access=public)
        [errMsg,newValue]=doReplace(blockCache,replaceData)
    end
end
