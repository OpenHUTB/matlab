classdef ( Sealed )PerspectiveAdapter < coderapp.internal.config.runtime.InternalNodeAdapter

    properties ( Constant )
        NodeType coderapp.internal.config.runtime.NodeType = coderapp.internal.config.runtime.NodeType.Perspective
    end

    properties ( Dependent, SetAccess = private )
        DependencyKeys
    end

    properties ( Dependent )
        IsActive logical
    end

    properties ( Dependent, SetAccess = immutable )
        IsDefault logical
    end

    properties ( SetAccess = immutable )
        PerspectiveDef
    end

    properties ( Access = private )
        MemberNodes
    end

    methods
        function this = PerspectiveAdapter( perDef )
            arguments
                perDef coderapp.internal.config.schema.PerspectiveDef
            end
            this@coderapp.internal.config.runtime.InternalNodeAdapter( perDef );
            this.PerspectiveDef = perDef;
        end

        function keys = get.DependencyKeys( ~ )
            keys = {  };
        end

        function active = get.IsActive( this )
            active = this.State.IsActive;
        end

        function set.IsActive( this, active )
            this.State.IsActive = active;
        end

        function default = get.IsDefault( this )
            default = this.State.IsDefault;
        end
    end

    methods ( Access = protected )
        function depNodes = getDependencyNodes( ~ )
            depNodes = [  ];
        end
    end
end

