classdef(Hidden,Sealed)CompPort<autosar.arch.PortBase





    methods(Hidden,Static)
        function this=create(portH)

            this=autosar.arch.CompPort(portH);
        end
    end

    methods(Hidden,Access=private)
        function this=CompPort(portH)




            assert(autosar.arch.Utils.isPort(portH),...
            'specified portH is not a port handle.');


            this@autosar.arch.PortBase(portH);
        end
    end

    methods(Hidden,Access=protected)
        function destroyImpl(this)


            this.checkValidSimulinkHandle();


            rootModelH=this.getRootArchModelH();
            parentObj=this.Parent;


            slPortBlk=autosar.arch.Utils.findSLPortBlock(this.SimulinkHandle);



            cellfun(@(x)delete_block(x),slPortBlk);



            if autosar.arch.Utils.isModelBlock(parentObj.SimulinkHandle)
                autosar.arch.Utils.refreshModelBlocksReferencingModel(...
                rootModelH,parentObj.ReferenceName);
            end

            delete(this);
        end

        function portName=getPortName(this)

            this.checkValidSimulinkHandle();


            slPortBlk=autosar.arch.Utils.findSLPortBlock(this.SimulinkHandle);

            portName=get_param(slPortBlk{1},'PortName');
        end

        function setPortName(this,newName)

            this.checkValidSimulinkHandle();


            slPortBlk=autosar.arch.Utils.findSLPortBlock(this.SimulinkHandle);
            if(length(slPortBlk)==1)&&~autosar.arch.Utils.isBusPortBlock(slPortBlk{1})
                DAStudio.error('autosarstandard:api:CannotSetNameForNonBusPort',...
                getfullname(slPortBlk{1}));
            end

            set_param(slPortBlk{1},'PortName',newName);
            if strcmp(get_param(this.Parent.SimulinkHandle,'BlockType'),'ModelReference')
                Simulink.ModelReference.refresh(this.Parent.SimulinkHandle);
            end
        end

        function p=getParent(this)

            this.checkValidSimulinkHandle();

            parentH=get_param(get_param(this.SimulinkHandle,'Parent'),'Handle');
            if autosar.composition.Utils.isCompositionBlock(parentH)
                p=autosar.arch.Composition.create(parentH);
            elseif autosar.composition.Utils.isAdapterBlock(parentH)
                p=autosar.arch.Adapter.create(parentH);
            else
                p=autosar.arch.Component.create(parentH);
            end
        end

        function portKind=getPortKind(this)

            this.checkValidSimulinkHandle();

            portType=get_param(this.SimulinkHandle,'PortType');
            if strcmp(portType,'outport')
                portKind='Sender';
            else
                assert(strcmp(portType,'inport'),'unexpected port type: %s',portType);
                portKind='Receiver';
            end
        end

        function isConnected=getIsConnected(this)

            this.checkValidSimulinkHandle();

            lineH=get_param(this.SimulinkHandle,'Line');
            isConnected=(lineH~=-1)&&strcmp(get_param(lineH,'Connected'),'on');
        end
    end

    methods(Hidden,Access=public)
        function archPort=getArchPort(this)
            assert(isa(this.Parent,'autosar.arch.Composition'),...
            'getArchPort is only supported for ports owned by a composition!');
            slPortBlk=autosar.arch.Utils.findSLPortBlock(this.SimulinkHandle);
            archPort=autosar.arch.ArchPort.create(slPortBlk{1});
        end

        function portH=getPortH(this)
            portH=this.SimulinkHandle;
        end
    end
end


