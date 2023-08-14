



classdef ReplacedInfoManager<handle

    methods(Access=public)
        function obj=ReplacedInfoManager()
            obj.replacedInfos={};
        end

        function addReplacedInfo(this,propertyId,propertyData)
            import simulink.search.internal.model.ReplacedInfo;
            this.replacedInfos{end+1}=ReplacedInfo(propertyId,propertyData);
        end

        function reset(this)
            this.replacedInfos={};
        end
    end

    properties(Access=public)
        replacedInfos={};
    end
end
