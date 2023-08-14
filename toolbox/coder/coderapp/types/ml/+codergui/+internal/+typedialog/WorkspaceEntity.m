classdef(Sealed)WorkspaceEntity




    properties(SetAccess=immutable)
        EntityId uint32
    end

    properties
        Name char=''
        WhosInfo struct
        Promotable logical=false
        IsBaseWorkspace logical=false
    end

    properties(Dependent,SetAccess=immutable)
IsCoderType
    end

    properties(Hidden,Transient)
CoderTypeObject
    end

    methods
        function this=WorkspaceEntity(entityId)
            this.EntityId=entityId;
        end

        function yes=get.IsCoderType(this)
            yes=~isempty(this.CoderTypeObject)||(~isempty(this.WhosInfo)&&...
            isCoderTypeSubclass(this.WhosInfo.class));
        end
    end
end


function yes=isCoderTypeSubclass(className)
    yes=ismember('coder.Type',superclasses(className));
end
