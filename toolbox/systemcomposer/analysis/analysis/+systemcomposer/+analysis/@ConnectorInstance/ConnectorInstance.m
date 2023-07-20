classdef ConnectorInstance<systemcomposer.analysis.Instance




    properties(SetAccess=private,Dependent)
Ports
Specification
Parent
QualifiedName
    end

    properties(SetAccess=private,Hidden,Dependent)
SourcePort
DestinationPort
    end


    methods
        function parent=get.Parent(this)
            parentImpl=this.InstElementImpl.parent;
            if isempty(parentImpl.parent)
                parent=this.getWrapperForImpl(parentImpl.instanceModel,'systemcomposer.analysis.ArchitectureInstance');
            else
                parent=this.getWrapperForImpl(parentImpl,'systemcomposer.analysis.ComponentInstance');
            end
        end

        function specification=get.Specification(this)
            specification=systemcomposer.arch.Connector.empty;
            try
                specification=systemcomposer.internal.getWrapperForImpl(this.InstElementImpl.specification);
            catch
            end
        end

        function sPort=get.SourcePort(this)
            if isa(this.InstElementImpl.specification,'systemcomposer.architecture.model.design.NAryConnector')
                error('systemcomposer:analysis:invalidConnectorInstanceType',message('SystemArchitecture:Analysis:InvalidConnectorInstanceType').getString);
            end
            warning('systemcomposer:analysis:WarningSourcePort',message('SystemArchitecture:Analysis:WarningSourcePort').getString);
            sPortImpl=this.InstElementImpl.connectorEnds(1);
            sPort=this.getWrapperForImpl(sPortImpl,'systemcomposer.analysis.PortInstance');
        end

        function dPort=get.DestinationPort(this)
            if isa(this.InstElementImpl.specification,'systemcomposer.architecture.model.design.NAryConnector')
                error('systemcomposer:analysis:invalidConnectorInstanceType',message('SystemArchitecture:Analysis:InvalidConnectorInstanceType').getString);
            end
            warning('systemcomposer:analysis:WarningDestinationPort',message('SystemArchitecture:Analysis:WarningDestinationPort').getString);
            dPortImpl=this.InstElementImpl.connectorEnds(2);
            dPort=this.getWrapperForImpl(dPortImpl,'systemcomposer.analysis.PortInstance');
        end

        function ports=get.Ports(this)
            ports={};
            for idx=1:this.InstElementImpl.connectorEnds.Size
                portImpl=this.InstElementImpl.connectorEnds(idx);
                ports{end+1}=this.getWrapperForImpl(portImpl,'systemcomposer.analysis.PortInstance');
            end
        end

        function name=get.QualifiedName(this)
            ports=this.Ports;
            portQualifiedNames=cellfun(@(x)x.QualifiedName,ports,'UniformOutput',false);
            name=join(portQualifiedNames,'->');
        end

    end

end
