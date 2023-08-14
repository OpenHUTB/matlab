classdef(Abstract,Hidden)Instance<systemcomposer.analysis.AbstractInstanceElement


    properties(SetAccess=private,Dependent)
Name
    end

    properties(SetAccess=private,Abstract,Dependent,Hidden)
Specification
QualifiedName
    end

    methods
        function this=Instance(instElemImpl)
            narginchk(1,1);
            this@systemcomposer.analysis.AbstractInstanceElement(instElemImpl);
        end
    end

    methods(Access=public)
        function res=isConnector(this)
            res=isa(this.InstElementImpl,'systemcomposer.internal.analysis.ConnectorInstance');
        end

        function res=isComponent(this)
            res=isa(this,'systemcomposer.analysis.NodeInstance');
        end

        function res=isPort(this)
            res=isa(this.InstElementImpl,'systemcomposer.internal.analysis.PortInstance');
        end

        function res=isArchitecture(this)
            res=isa(this.InstElementImpl,'systemcomposer.internal.analysis.ArchitectureInstance');
        end
    end

    methods
        function name=get.Name(this)
            name=this.getInstance.getName;
        end
    end

    methods(Hidden)




        function inst=getInstance(this)
            inst=this.InstElementImpl;
        end
    end

end

