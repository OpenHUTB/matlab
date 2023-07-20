classdef(Abstract,Hidden)NodeInstance<systemcomposer.analysis.Instance


    properties(SetAccess=private,Dependent)

Components

Ports

Connectors
    end

    properties(SetAccess=private,Dependent,Hidden)
QualifiedName
    end

    methods(Access='protected')
        qualifiedName=getQualifiedName(this);
        function instance=findInstanceFromQualifiedName(this,qualifiedName)


            if strcmp(qualifiedName,this.Name)
                instance=this;
            else
                impl=this.getInstance.findInstanceFromQualifiedName(qualifiedName);
                if isa(impl,'systemcomposer.internal.analysis.NodeInstance')
                    instance=this.getWrapperForImpl(impl,'systemcomposer.analysis.ComponentInstance');
                elseif isa(impl,'systemcomposer.internal.analysis.PortInstance')
                    instance=this.getWrapperForImpl(impl,'systemcomposer.analysis.PortInstance');
                else
                    instance=this.getWrapperForImpl(impl,'systemcomposer.analysis.ConnectorInstance');
                end
            end
        end
    end
    methods

        function name=get.QualifiedName(this)
            name=this.getQualifiedName();
        end

        function children=get.Components(this)
            ch=this.getInstance.children.toArray;
            children=systemcomposer.analysis.ComponentInstance.empty;
            for i=1:numel(ch)
                children(end+1)=this.getWrapperForImpl(ch(i),'systemcomposer.analysis.ComponentInstance');
            end
        end

        function ports=get.Ports(this)
            ch=this.getInstance.ports.toArray;
            ports=systemcomposer.analysis.PortInstance.empty;
            for i=1:numel(ch)
                ports(end+1)=this.getWrapperForImpl(ch(i),'systemcomposer.analysis.PortInstance');
            end
        end

        function conn=get.Connectors(this)
            ch=this.getInstance.connectors.toArray;
            conn=systemcomposer.analysis.ConnectorInstance.empty;
            for i=1:numel(ch)
                conn(end+1)=this.getWrapperForImpl(ch(i),'systemcomposer.analysis.ConnectorInstance');
            end
        end


    end

end

