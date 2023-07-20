classdef(Hidden,Sealed)ArchPort<autosar.arch.PortBase




    methods(Hidden,Static)
        function this=create(portBlkH)

            this=autosar.arch.ArchPort(portBlkH);
        end
    end

    methods(Hidden,Access=private)
        function this=ArchPort(portBlkH)




            assert(autosar.arch.Utils.isBusPortBlock(portBlkH),...
            'specified portBlockH is not a port block');

            this@autosar.arch.PortBase(portBlkH);
        end
    end

    methods(Hidden,Access=protected)
        function destroyImpl(this)

            this.checkValidSimulinkHandle();

            delete_block(this.SimulinkHandle);
            delete(this);
        end


        function parent=getParent(this)

            this.checkValidSimulinkHandle();


            portBlkOwner=get_param(get_param(this.SimulinkHandle,'Parent'),'Handle');
            isPortBlkOwnerAtRootLevel=isequal(portBlkOwner,bdroot(this.SimulinkHandle));
            if isPortBlkOwnerAtRootLevel

                parent=autosar.arch.Model.create(this.getRootArchModelH());
            else

                if autosar.composition.Utils.isCompositionBlock(portBlkOwner)
                    parent=autosar.arch.Composition.create(portBlkOwner);
                else
                    assert(autosar.composition.Utils.isComponentBlock(portBlkOwner),...
                    '%s should be a component block.',getfullname(portBlkOwner));
                    parent=autosar.arch.Component.create(portBlkOwner);
                end
            end
        end

        function portName=getPortName(this)

            this.checkValidSimulinkHandle();

            portName=get_param(this.SimulinkHandle,'PortName');
        end

        function setPortName(this,newName)

            this.checkValidSimulinkHandle();

            set_param(this.SimulinkHandle,'PortName',newName);
        end

        function portKind=getPortKind(this)

            this.checkValidSimulinkHandle();

            blockType=get_param(this.SimulinkHandle,'BlockType');
            if strcmp(blockType,'Outport')
                portKind='Sender';
            else
                assert(strcmp(blockType,'Inport'),'unexpected port type: %s',blockType);
                portKind='Receiver';
            end
        end

        function isConnected=getIsConnected(this)

            this.checkValidSimulinkHandle();

            ph=get_param(this.SimulinkHandle,'PortHandles');
            if strcmp(get_param(this.SimulinkHandle,'BlockType'),'Inport')
                lineH=get_param(ph.Outport,'Line');
            else
                lineH=get_param(ph.Inport,'Line');
            end
            isConnected=(lineH~=-1)&&strcmp(get_param(lineH,'Connected'),'on');
        end
    end

    methods(Hidden,Access=public)
        function portH=getPortH(this)
            ph=get_param(this.SimulinkHandle,'PortHandles');
            if strcmp(get_param(this.SimulinkHandle,'BlockType'),'Inport')
                portH=ph.Outport;
            else
                portH=ph.Inport;
            end
        end
    end
end
