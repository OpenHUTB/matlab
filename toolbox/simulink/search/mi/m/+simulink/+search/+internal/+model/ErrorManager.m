



classdef ErrorManager<handle

    methods(Access=public)
        function obj=ErrorManager()
            obj.errorInfos={};
        end

        function reset(this)
            this.errorInfos={};
        end

        function addErrorInfo(this,timeStamp,blockUri,propId,errorMessage)
            import simulink.search.internal.model.ErrorInfo;
            this.errorInfos{end+1}=ErrorInfo(timeStamp,blockUri,propId,errorMessage);
        end
    end

    properties(Access=public)
        errorInfos=[];
    end
end
