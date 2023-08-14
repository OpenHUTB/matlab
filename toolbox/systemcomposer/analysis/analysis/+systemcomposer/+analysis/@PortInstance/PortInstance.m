classdef PortInstance<systemcomposer.analysis.Instance




    properties(SetAccess=private,Dependent)
Specification
Parent
QualifiedName
Incoming
Outgoing
    end

    methods
        function incoming=get.Incoming(this)
            incoming=systemcomposer.analysis.ConnectorInstance.empty;
            ch=this.InstElementImpl.connector.toArray;
            for i=1:numel(ch)
                connEnds=ch(i).connectorEnds.toArray;
                incomingEnds=connEnds(2:end);
                for m=1:numel(incomingEnds)
                    if isequal(incomingEnds(m),this.InstElementImpl)
                        incoming(end+1)=this.getWrapperForImpl(ch(i),'systemcomposer.analysis.ConnectorInstance');
                    end
                end
            end
        end

        function outgoing=get.Outgoing(this)
            outgoing=systemcomposer.analysis.ConnectorInstance.empty;
            ch=this.InstElementImpl.connector.toArray;
            for i=1:numel(ch)
                connEnds=ch(i).connectorEnds.toArray;
                if isequal(connEnds(1),this.InstElementImpl)
                    outgoing(end+1)=this.getWrapperForImpl(ch(i),'systemcomposer.analysis.ConnectorInstance');
                end
            end
        end

        function parent=get.Parent(this)
            parentImpl=this.InstElementImpl.parent;
            if isempty(parentImpl.parent)
                parent=this.getWrapperForImpl(parentImpl.instanceModel,'systemcomposer.analysis.ArchitectureInstance');
            else
                parent=this.getWrapperForImpl(parentImpl,'systemcomposer.analysis.ComponentInstance');
            end
        end

        function specification=get.Specification(this)
            try
                implSpec=this.InstElementImpl.specification;
            catch
                specification=systemcomposer.arch.ArchitecturePort.empty;
                return;
            end

            specification=systemcomposer.internal.getWrapperForImpl(implSpec);
        end

        function name=get.QualifiedName(this)
            base=this.Parent.QualifiedName;
            name=[base,':',this.Name];
        end
    end
end
