function portHandle=getPortHandleForConnection(this,elem)




    if this.getImpl.isArchitecturePort&&this.Direction~=systemcomposer.arch.PortDirection.Physical

        if(this.Parent.getImpl.getDefinition()==systemcomposer.architecture.model.core.DefinitionType.BEHAVIOR)

            error('Connections are not allowed for architecture ports in implementation models');
        end








        if this.hasAnonymousCompositeInterface


            assert(nargin>1);



            if this.Direction==systemcomposer.arch.PortDirection.Output&&isempty(elem)
                error(message('SystemArchitecture:API:DestinationElemRequiredForOutputWithComposite'));
            end

            slPortBlock=systemcomposer.utils.getSimulinkPeer(this.getImpl);
            slPortBlock=slPortBlock(strcmp(get_param(slPortBlock,'Element'),elem));
            if~isempty(slPortBlock)
                slConnInfo=get_param(slPortBlock,'PortConnectivity');
                if~iscell(slConnInfo)
                    slConnInfo={slConnInfo};
                end
                unconnectedSlPortBlock=slPortBlock(cellfun(@(x)isempty(x.DstBlock)&&(isempty(x.SrcBlock)||x.SrcBlock==-1),slConnInfo));
                if~isempty(unconnectedSlPortBlock)
                    portHandle=unconnectedSlPortBlock(1);
                    return;
                end
            end



            handleToDuplicate=systemcomposer.utils.getSimulinkPeer(this.getImpl);
            handleToDuplicate=handleToDuplicate(1);
            if(this.Direction==systemcomposer.arch.PortDirection.Input)
                fullPortName=[this.Parent.getQualifiedName,'/In Bus Element1'];
            else
                assert(this.Direction==systemcomposer.arch.PortDirection.Output);
                fullPortName=[this.Parent.getQualifiedName,'/Out Bus Element1'];
            end
            portHandle=add_block(handleToDuplicate,...
            fullPortName,'MakeNameUnique','on');
            set_param(portHandle,'Element',elem);
            return;
        end

        if~isempty(this.getImpl.getConnectors)

            handleToDuplicate=systemcomposer.utils.getSimulinkPeer(this.getImpl);
            handleToDuplicate=handleToDuplicate(1);
            if(this.Direction==systemcomposer.arch.PortDirection.Input)
                fullPortName=[this.Parent.getQualifiedName,'/In Bus Element1'];
            else
                assert(this.Direction==systemcomposer.arch.PortDirection.Output);
                fullPortName=[this.Parent.getQualifiedName,'/Out Bus Element1'];
            end
            portHandle=add_block(handleToDuplicate,...
            fullPortName,'MakeNameUnique','on');
        else


            portHandle=systemcomposer.utils.getSimulinkPeer(this.getImpl);
            assert(length(portHandle)==1);
        end
    else
        assert(this.getImpl.isComponentPort||this.Direction==systemcomposer.arch.PortDirection.Physical);
        portHandle=systemcomposer.utils.getSimulinkPeer(this.getImpl);
    end
end

