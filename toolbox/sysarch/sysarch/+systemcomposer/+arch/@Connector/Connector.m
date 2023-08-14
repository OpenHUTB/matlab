classdef Connector<systemcomposer.arch.BaseConnector





    properties(SetAccess=private)
SourcePort
DestinationPort
    end

    methods(Hidden)
        function this=Connector(archElemImpl)

            narginchk(1,1);
            if~isa(archElemImpl,'systemcomposer.architecture.model.design.BinaryConnector')
                error('systemcomposer:API:ConnectorInvalidInput',message('SystemArchitecture:API:ConnectorInvalidInput').getString);
            end
            this@systemcomposer.arch.BaseConnector(archElemImpl);
            archElemImpl.cachedWrapper=this;

        end
    end

    methods
        function sPort=get.SourcePort(this)
            sPortImpl=this.ElementImpl.getSource;
            if isa(sPortImpl,'systemcomposer.architecture.model.design.ComponentPort')
                sPort=systemcomposer.internal.getWrapperForImpl(sPortImpl,'systemcomposer.arch.ComponentPort');
            else
                sPort=systemcomposer.internal.getWrapperForImpl(sPortImpl,'systemcomposer.arch.ArchitecturePort');
            end
        end

        function dPort=get.DestinationPort(this)
            dPortImpl=this.ElementImpl.getDestination;
            if isa(dPortImpl,'systemcomposer.architecture.model.design.ComponentPort')
                dPort=systemcomposer.internal.getWrapperForImpl(dPortImpl,'systemcomposer.arch.ComponentPort');
            else
                dPort=systemcomposer.internal.getWrapperForImpl(dPortImpl,'systemcomposer.arch.ArchitecturePort');
            end
        end
    end

    methods(Access=protected)
        function ports=getPortsImpl(this)
            ports=[this.SourcePort,this.DestinationPort];
        end

        function blks=getSLBlocksToDeleteOnConnectorDestroy(this,lineObj)
            blks=[];
            if(this.SourcePort.getImpl.isArchitecturePort&&...
                numel(systemcomposer.utils.getSimulinkPeer(this.SourcePort.getImpl))>1)
                if(this.SourcePort.hasAnonymousCompositeInterface&&~isempty(this.getSourceElement{1}))



                    slPortBlock=systemcomposer.utils.getSimulinkPeer(this.SourcePort.getImpl);
                    slPortBlock=slPortBlock(strcmp(get_param(slPortBlock,'Element'),this.getSourceElement{1}));
                    slConnInfo=get_param(slPortBlock,'PortConnectivity');
                    if~iscell(slConnInfo)
                        slConnInfo={slConnInfo};
                    end
                    isConnectedSet=cellfun(@(x)~isempty(x.DstBlock)||~isempty(x.SrcBlock),slConnInfo);
                    if(sum(double(isConnectedSet))>1)
                        blks=[blks,lineObj.SrcBlock];
                    end
                else

                    blks=[blks,lineObj.SrcBlock];
                end
            end

            if(this.DestinationPort.getImpl.isArchitecturePort&&...
                numel(systemcomposer.utils.getSimulinkPeer(this.DestinationPort.getImpl))>1)
                if(this.DestinationPort.hasAnonymousCompositeInterface&&~isempty(this.getDestinationElement{1}))



                    slPortBlock=systemcomposer.utils.getSimulinkPeer(this.DestinationPort.getImpl);
                    slPortBlock=slPortBlock(strcmp(get_param(slPortBlock,'Element'),this.getDestinationElement{1}));
                    slConnInfo=get_param(slPortBlock,'PortConnectivity');
                    if~iscell(slConnInfo)
                        slConnInfo={slConnInfo};
                    end
                    isConnectedSet=cellfun(@(x)~isempty(x.DstBlock)||~isempty(x.SrcBlock),slConnInfo);
                    if(sum(double(isConnectedSet))>1)
                        blks=[blks,lineObj.DstBlock];
                    end
                else

                    blks=[blks,lineObj.DstBlock];
                end
            end

        end

        function skipLineDelete=shouldSkipLineDeleteOnConnectorDestroy(this,lineObj)
            skipLineDelete=false;
            if(this.DestinationPort.getImpl.isArchitecturePort&&...
                numel(systemcomposer.utils.getSimulinkPeer(this.DestinationPort.getImpl))>1)
                if(this.DestinationPort.hasAnonymousCompositeInterface&&~isempty(this.getDestinationElement{1}))
                    if~strcmpi(this.getDestinationElement{1},get_param(lineObj.DstBlock,'Element'))


                        skipLineDelete=true;
                    end
                end
            end

        end

    end

    methods
        srcElem=getSourceElement(this);
        dstElem=getDestinationElement(this);
    end

end
