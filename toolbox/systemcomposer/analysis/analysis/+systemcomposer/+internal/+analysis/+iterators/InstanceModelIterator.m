classdef InstanceModelIterator<internal.systemcomposer.HierarchyIterator
    properties(Access=protected)
        ValueSet;
        IncludePorts=false;
        IncludeConnectors=false;
    end

    methods
        function elem=getElement(this)
            if isempty(this.ValueSet)
                elemImpl=this.CurrentElement;
            else
                elemImpl=this.CurrentElement.propertyValues.getByKey(this.ValueSet.UUID);
            end
            if~isempty(elemImpl)
                if isempty(elemImpl.parent)
                    elem=systemcomposer.analysis.ArchitectureInstance.getWrapperForImpl(...
                    elemImpl.instanceModel,'systemcomposer.analysis.ArchitectureInstance');
                else
                    if isa(elemImpl,'systemcomposer.internal.analysis.NodeInstance')
                        elem=systemcomposer.analysis.ComponentInstance.getWrapperForImpl(...
                        elemImpl,'systemcomposer.analysis.ComponentInstance');
                    elseif isa(elemImpl,'systemcomposer.internal.analysis.PortInstance')
                        elem=systemcomposer.analysis.PortInstance.getWrapperForImpl(...
                        elemImpl,'systemcomposer.analysis.PortInstance');
                    else
                        elem=systemcomposer.analysis.ConnectorInstance.getWrapperForImpl(...
                        elemImpl,'systemcomposer.analysis.ConnectorInstance');
                    end
                end
            else
                elem=[];
            end
        end
        function this=InstanceModelIterator(direction,includePorts,includeConnectors)
            this@internal.systemcomposer.HierarchyIterator(direction);
            if nargin>1
                this.IncludePorts=includePorts;
                if nargin>2
                    this.IncludeConnectors=includeConnectors;
                end
            end
        end
    end
    methods(Access=protected)
        function comps=getChildComponents(this,elem)
            if isa(elem,'systemcomposer.internal.analysis.NodeInstance')
                comps=elem.children.toArray;
                if(this.IncludePorts)
                    comps=[comps,elem.ports.toArray];
                end

                if(this.IncludeConnectors)
                    comps=[comps,elem.connectors.toArray];
                end
            else
                comps=[];
            end
        end

        function mod=validateStartNode(this,startNode)
            if isa(startNode,'systemcomposer.internal.analysis.ArchitectureInstance')
                mod=startNode.root;
            elseif isa(startNode,'systemcomposer.internal.analysis.NodeInstance')
                mod=startNode;
            else
                mod=[];
            end
            this.ValueSet=systemcomposer.internal.analysis.ModelValueSet.empty;
        end

    end
end