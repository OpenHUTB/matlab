

classdef FunctionBlockReplaceProcessor<simulink.search.internal.control.DefaultReplaceProcessor
    properties(Access=protected)
        m_funcConfigObj=[];
    end

    methods(Access=public)
        function obj=FunctionBlockReplaceProcessor()
            obj@simulink.search.internal.control.DefaultReplaceProcessor();
            obj.m_funcConfigObj=[];
        end

        function[errMsg,newValue]=doReplace(this,blockCache,replaceData)
            this.resetStateParams(blockCache,replaceData);
            try




                this.m_funcConfigObj=get_param(...
                blockCache.handle,...
'MATLABFunctionConfiguration'...
                );
            catch ex
                errMsg=ex.message;
                return;
            end
            [errMsg,newValue]=doReplace@simulink.search.internal.control.DefaultReplaceProcessor(...
            this,blockCache,replaceData...
            );
        end
    end

    methods(Access=protected)
        function generatePropertyName(this)
        end

        function generateCurrentValue(this)
            try
                this.m_replaceParam.currentValue=this.m_funcConfigObj.FunctionScript;
            catch ex
                this.m_replaceParam.errMsg=ex.message;
            end
        end

        function doReplaceAction(this)
            try
                this.m_funcConfigObj.FunctionScript=this.m_replaceParam.newValue;
            catch ME
                this.m_replaceParam.errMsg=ME.message;
            end
        end
    end
end
