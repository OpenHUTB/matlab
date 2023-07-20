classdef VirtualBusCheck<handle




    properties(SetAccess=private,GetAccess=public)
Systems
NewModels
ConversionData
        Logger;

        Inports={};
        Outports={};
        OutportBlockMasks={};
SignalConversionBlock
    end

    methods(Access=public)
        function this=VirtualBusCheck(params)
            this.Systems=params.ConversionParameters.Systems;
            this.NewModels=params.ConversionParameters.ModelReferenceNames;
            this.ConversionData=params;
            this.Logger=this.ConversionData.Logger;
            this.init;
            this.SignalConversionBlock=Simulink.ModelReference.Conversion.SignalConversionBlock(this.ConversionData);
        end

        function check(this)
            this.Inports=cellfun(@(item)this.checkInport(item),this.Inports,'UniformOutput',false);
            this.Outports=cellfun(@(item)this.checkOutport(item),this.Outports,'UniformOutput',false);
        end

        function updateNewModels(this,system2ModelMap)
            N=length(this.Systems);
            for idx=1:N
                currentSubsystem=this.Systems(idx);
                newModel=get_param(system2ModelMap(currentSubsystem),'Name');
                this.outputAsStruct(strcat(newModel,'/',this.Inports{idx}));
                this.outputAsStruct(strcat(newModel,'/',this.Outports{idx}));
            end
        end



        function insertSignalConversionBlocks(this)
            if this.ConversionData.ConversionParameters.ReplaceSubsystem
                if~isempty(this.OutportBlockMasks)
                    arrayfun(@(ssIdx)this.SignalConversionBlock.insert(this.Systems(ssIdx),this.OutportBlockMasks{ssIdx}),...
                    1:numel(this.Systems));
                end
            end
        end
    end

    methods(Access=private)
        function init(this)
            this.Inports=arrayfun(@(ss)Simulink.ModelReference.Conversion.Utilities.findRootLevelPortBlocks(ss,'Inport'),...
            this.Systems,'UniformOutput',false);
            this.Outports=arrayfun(@(ss)Simulink.ModelReference.Conversion.Utilities.findRootLevelPortBlocks(ss,'Outport'),...
            this.Systems,'UniformOutput',false);
        end

        function results=checkInport(this,inports)
            portBlocks=arrayfun(@(ph)ph.Outport,...
            arrayfun(@(aPort)get_param(aPort,'PortHandles'),inports));
            mask=arrayfun(@(ph)this.isSupported(ph),portBlocks);
            if any(mask)
                results=Simulink.ModelReference.Conversion.Utilities.cellify(get_param(inports(mask),'Name'));
            else
                results={};
            end
        end

        function results=checkOutport(this,ports)
            portBlocks=arrayfun(@(ph)ph.Inport,...
            arrayfun(@(aPort)get_param(aPort,'PortHandles'),ports));
            mask=arrayfun(@(ph)this.isSupported(ph),portBlocks);
            this.OutportBlockMasks{end+1}=mask;
            if any(mask)
                results=Simulink.ModelReference.Conversion.Utilities.cellify(get_param(ports(mask),'Name'));
            else
                results={};
            end
        end

        function outputAsStruct(~,ports)
            for ii=1:numel(ports)
                port=ports{ii};
                if~Simulink.ModelReference.Conversion.isBusElementPort(port)
                    set_param(port,'BusOutputAsStruct','on');
                end
            end
        end

        function status=isSupported(~,blk)
            status=(strcmp(get_param(blk,'CompiledBusType'),'VIRTUAL_BUS')&&...
            any(get_param(blk,'CompiledPortDimensionsMode')));
        end
    end
end


