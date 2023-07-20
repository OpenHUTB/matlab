classdef FPTSupport<handle

    methods(Static)

        function overrideConvertedMATLABFunctionBlocks(modelName,variantOverride)
            assert(isa(variantOverride,'coder.internal.MLFcnBlock.VariantOverrideEnum'));
            coder.internal.MLFcnBlock.FPTSupport.overrideConvertedMATLABFunctionBlocksImpl(modelName,variantOverride);
        end

    end


    methods(Static,Access=private)
        function overrideConvertedMATLABFunctionBlocksImpl(modelName,variantOverride)
            this=coder.internal.MLFcnBlock.FPTSupport();
            emlBlocks=this.getEmlBlocks(modelName);
            for ii=1:numel(emlBlocks)
                chart=emlBlocks(ii);
                mlfb=chart.Path;
                varSubSys=get_param(mlfb,'Parent');
                [origMLFB,fixptMLFB]=this.fetchMLFBVariants(varSubSys);
                if~isempty(origMLFB)||~isempty(fixptMLFB)
                    switch variantOverride
                    case coder.internal.MLFcnBlock.VariantOverrideEnum.NoOverride

                        set_param(varSubSys,'LabelModeActiveChoice','');
                        coder.internal.MLFcnBlock.FPTSupport.alignVariantSubsystemPorts(varSubSys,fixptMLFB);

                    case coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingOriginal
                        if~isempty(origMLFB)
                            set_param(varSubSys,'LabelModeActiveChoice',get_param(origMLFB,'VariantControl'));
                        end
                        coder.internal.MLFcnBlock.FPTSupport.alignVariantSubsystemPorts(varSubSys,origMLFB);

                    case coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingFixedPoint
                        if~isempty(fixptMLFB)
                            set_param(varSubSys,'LabelModeActiveChoice',get_param(fixptMLFB,'VariantControl'));
                        end
                        coder.internal.MLFcnBlock.FPTSupport.alignVariantSubsystemPorts(varSubSys,fixptMLFB);

                    otherwise
                        assert(false);
                    end
                end
            end
        end

        function emlBlocks=getEmlBlocks(modelName)
            r=sfroot;
            m=r.find('-isa','Stateflow.Machine','Name',modelName);
            emlBlocks=[];
            if~isempty(m)
                emCharts=m.find('-isa','Stateflow.EMChart');
                emLinkCharts=m.find('-isa','Stateflow.LinkChart');
                emlBlocks=[emCharts;emLinkCharts];
            end
        end

        function[origMLFB,fixptMLFB]=fetchMLFBVariants(varSubSys)
            [origMLFB,fixptMLFB]=coder.internal.mlfb.getMlfbVariants(varSubSys);
        end

        function alignVariantSubsystemPorts(varSubsys,activeVariant)
            try
                if isempty(activeVariant)
                    return;
                end

                blockNames=get_param(varSubsys,'blocks');
                if isempty(blockNames)
                    return;
                end

                blocks={};
                for ii=1:numel(blockNames)
                    blk=sprintf('%s/%s',varSubsys,blockNames{ii});
                    blocks{end+1}=blk;
                end

                inports={};
                outports={};

                for ii=1:numel(blocks)
                    blk=blocks{ii};
                    switch get_param(blk,'blocktype')
                    case{'Inport'},inports{end+1}=blk;
                    case{'Outport'},outports{end+1}=blk;
                    end
                end

                offset=5;
                for ii=1:numel(inports)
                    inportPos=get_param(inports{ii},'position');
                    portPos=getPortPosition(activeVariant,-ii);
                    d=portPos(2)-inportPos(2)-offset;
                    set_param(inports{ii},'position',inportPos+[0,d,0,d]);
                end

                for ii=1:numel(outports)
                    outportPos=get_param(outports{ii},'position');
                    portPos=getPortPosition(activeVariant,ii);
                    d=portPos(2)-outportPos(2)-offset;
                    set_param(outports{ii},'position',outportPos+[0,d,0,d]);
                end
            catch
            end

            function portPos=getPortPosition(blk,portIdx)
                portH=get_param(blk,'PortHandles');
                if portIdx<0

                    port=portH.Inport(-portIdx);
                else
                    port=portH.Outport(portIdx);
                end
                portPos=get_param(port,'position');
            end
        end
    end
end
