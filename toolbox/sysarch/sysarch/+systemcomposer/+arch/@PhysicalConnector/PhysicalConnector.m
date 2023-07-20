classdef PhysicalConnector<systemcomposer.arch.BaseConnector




    methods
        function this=PhysicalConnector(archElemImpl)

            narginchk(1,1);
            if~isa(archElemImpl,'systemcomposer.architecture.model.design.NAryConnector')
                error('systemcomposer:API:ConnectorInvalidInput',message('SystemArchitecture:API:ConnectorInvalidInput').getString);
            end
            this@systemcomposer.arch.BaseConnector(archElemImpl);
            archElemImpl.cachedWrapper=this;
        end

        function srcElem=getSourceElement(~)
            srcElem='';
        end

        function dstElem=getDestinationElement(~)
            dstElem='';
        end
    end

    methods(Access=protected)
        function ports=getPortsImpl(this)
            portImpls=this.ElementImpl.getPorts();
            ports=systemcomposer.arch.BasePort.empty;
            for idx=1:length(portImpls)
                ports(end+1)=systemcomposer.internal.getWrapperForImpl(portImpls(idx));%#ok<AGROW>
            end
        end

        function blks=getSLBlocksToDeleteOnConnectorDestroy(~,~)
            blks=[];
        end

        function skipLineDelete=shouldSkipLineDeleteOnConnectorDestroy(~,~)
            skipLineDelete=false;
        end

    end


end
