classdef(Abstract,AllowedSubclasses={...
    ?coderapp.internal.config.runtime.ReferableNodeAdapter,...
    ?coderapp.internal.config.runtime.InternalNodeAdapter})...
    NodeAdapter<coderapp.internal.log.Loggable&matlab.mixin.Heterogeneous


    properties(Abstract,Constant)
        NodeType coderapp.internal.config.runtime.NodeType
    end

    properties(Hidden,SetAccess=protected,Transient)
        Configuration coderapp.internal.config.Configuration
    end

    properties(SetAccess={?coderapp.internal.config.runtime.NodeAdapter,?coderapp.internal.config.Configuration})
        Propagate logical=false
    end

    properties(GetAccess=protected,SetAccess=private,Transient)
        ProfileIndex uint32
        IsTemporaryProfile logical=false
    end

    methods(Access={?coderapp.internal.config.runtime.NodeAdapter,?coderapp.internal.config.Configuration,...
        ?coderapp.internal.config.runtime.ConfigStoreAdapter})
        function initNode(this,configuration)
            this.Configuration=configuration;
        end

        function resetNode(~)
        end

        function updateNode(~,~)
        end

        function setLocked(~,locked)%#ok<INUSD>  
        end
    end
end
