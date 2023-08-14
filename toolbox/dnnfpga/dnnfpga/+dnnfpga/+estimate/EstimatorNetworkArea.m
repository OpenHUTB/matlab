classdef EstimatorNetworkArea<handle






    properties
cnnp
InternalArchParam
hPC
verbose
hwinfo
        resource=containers.Map
        TotalRAM=0
        TotalDSP=0
        LUTEnabled=false
    end

    methods

        function this=EstimatorNetworkArea(cnnp,hPC)
            this.cnnp=cnnp;
            this.hPC=hPC;
        end
    end

    methods
        function populateNetworkLayerArea(this)
            processors=this.getProcessors;

            for i=1:length(processors)
                processor=processors{i};
                moduleGeneration=this.getModuleGenerationProperty(processor);
                if~moduleGeneration
                    continue;
                end
                switch processor
                case 'conv'
                    Estimator=dnnfpga.estimate.ConvAreaEstimator(this.hPC,this.cnnp);
                    ConvpArea.dsp=Estimator.computeDSPResources;
                    ConvpArea.bram=Estimator.computeRAM;
                    this.resource(processor)=ConvpArea;

                    this.TotalRAM=this.TotalRAM+ConvpArea.bram;
                    this.TotalDSP=this.TotalDSP+ConvpArea.dsp;
                case 'fc'
                    Estimator=dnnfpga.estimate.FCAreaEstimator(this.hPC,this.cnnp);
                    FcpArea.dsp=Estimator.computeDSPResources;
                    FcpArea.bram=Estimator.computeRAM;
                    this.resource(processor)=FcpArea;

                    this.TotalRAM=this.TotalRAM+FcpArea.bram;
                    this.TotalDSP=this.TotalDSP+FcpArea.dsp;
                case 'custom'
                    Estimator=dnnfpga.estimate.CustomAreaEstimator(this.hPC,this.cnnp);
                    AdderArea.dsp=Estimator.computeDSPResources;
                    AdderArea.bram=Estimator.computeRAM;
                    this.resource(processor)=AdderArea;

                    this.TotalRAM=this.TotalRAM+AdderArea.bram;
                    this.TotalDSP=this.TotalDSP+AdderArea.dsp;
                case 'other'

                    Estimator=dnnfpga.estimate.DebugAreaEstimator(this.hPC,this.cnnp);
                    debug.dsp=Estimator.computeDSPResources;
                    debug.bram=Estimator.computeRAM;
                    this.resource(processor)=debug;

                    Estimator=dnnfpga.estimate.SchedulerAreaEstimator(this.hPC,this.cnnp);
                    schedulerArea.dsp=Estimator.computeDSPResources;
                    schedulerArea.bram=Estimator.computeRAM;

                    totalOtherArea.dsp=debug.dsp+schedulerArea.dsp;
                    totalOtherArea.bram=debug.bram+schedulerArea.bram;
                    this.resource(processor)=totalOtherArea;

                    this.TotalRAM=this.TotalRAM+totalOtherArea.bram;
                    this.TotalDSP=this.TotalDSP+totalOtherArea.dsp;
                otherwise
                    dnnfpga.disp(message('dnnfpga:workflow:IncorrectProcType',string(processor)));
                end
            end
        end

        function area=estimateArea(this,verbose,includeReferenceDesign)
            moduleName=this.getProcessors();
            DSP=[];
            blockRAM=[];
            RowNames={};
            LUT=[];
            LUTCount=dnnfpga.estimate.getLUTCount(this.hPC);





            try
                if contains(lower(this.hPC.SynthesisTool),"vivado")

                    toolFolder='+XilinxVivado_2020_1';
                    [DSPavailable,LUTavailable,RAMavailable]=dnnfpga.estimate.getAvailableCount(toolFolder,this.hPC.SynthesisToolDeviceName);
                    resourceCount.TotalLUT=LUTavailable;
                    resourceCount.TotalRAM=RAMavailable;
                    resourceCount.TotalDSP=DSPavailable;
                    RowNames{end+1}='Available';
                    DSP=[DSP;DSPavailable];
                    blockRAM=[blockRAM;RAMavailable];
                    LUT=[LUT;LUTavailable];
                    available=true;
                elseif contains(lower(this.hPC.SynthesisTool),"altera q")


                    resourceCount.TotalLUT=NaN;
                    resourceCount.TotalRAM=NaN;
                    resourceCount.TotalDSP=NaN;
                    available=false;
                end
            catch
                error(message('dnnfpga:config:CannotExtractResourceCount'));
            end


            if(includeReferenceDesign)
                hRD=this.hPC.getReferenceDesignObject;
                if(isempty(hRD))
                    warning(message('dnnfpga:config:GenericProcessorResourceEstimation'));
                elseif(hRD.ResourcesUsed.RAM==0&&hRD.ResourcesUsed.DSP==0&&hRD.ResourcesUsed.LogicElements==0)
                    error(message('dnnfpga:config:ReferenceDesignResourceMissing'));
                else
                    RowNames{end+1}='Total';
                    DSP=[DSP;hRD.ResourcesUsed.DSP+this.TotalDSP];
                    blockRAM=[blockRAM;hRD.ResourcesUsed.RAM+this.TotalRAM];
                    LUT=[LUT;hRD.ResourcesUsed.LogicElements+LUTCount];
                    RowNames{end+1}='ReferenceDesign';
                    DSP=[DSP;hRD.ResourcesUsed.DSP];
                    blockRAM=[blockRAM;hRD.ResourcesUsed.RAM];
                    LUT=[LUT;hRD.ResourcesUsed.LogicElements];
                end
            end

            RowNames{end+1}='DL_Processor';
            DSP=[DSP;this.TotalDSP];
            blockRAM=[blockRAM;this.TotalRAM];
            LUT=[LUT;LUTCount];
            for i=1:length(moduleName)
                moduleGeneration=this.getModuleGenerationProperty(moduleName{i});
                if~moduleGeneration
                    continue;
                end
                processorArea=this.resource(moduleName{i});
                RowNames{end+1}=strcat('____',moduleName{i},'_module');
                DSP=[DSP;processorArea.dsp];
                blockRAM=[blockRAM;processorArea.bram];
                LUT=[LUT;0];
            end
            area=table(DSP,blockRAM,LUT,'RowNames',RowNames);
            format=dnnfpga.estimate.FormatTable.getResourceTableFormat;
            if(verbose>=1)
                dnnfpga.estimate.FormatTable.printResourceTable(area,format,verbose,resourceCount,available);
            end

        end

        function processors=getProcessors(this)
            processors=this.hPC.getModuleIDList;

            processors{end+1}='other';
        end

        function moduleGeneration=getModuleGenerationProperty(this,moduleID)

            moduleGeneration=true;
            if this.hPC.isInModuleIDList(moduleID)



                moduleGeneration=this.hPC.getModule(moduleID).ModuleGeneration;
            end
        end
    end

end

