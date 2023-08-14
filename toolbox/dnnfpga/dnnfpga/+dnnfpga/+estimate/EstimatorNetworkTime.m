classdef EstimatorNetworkTime<handle





    properties
        cnnp=[];
        fpgaParamLayers=[];
        hPC=[];
        InternalArchParam=[];
verbose
        NetworkPerfomance=containers.Map;

frames

CalData
    end

    methods
        function this=EstimatorNetworkTime(cnnp,fpgaParamLayers,hPC,InternalArchParam,frames,verbose,calData)

            if isempty(InternalArchParam)
                this.InternalArchParam.kernelSize=3;
                this.InternalArchParam.perfectArch='false';

                this.InternalArchParam.doubleBuffer='false';
                this.InternalArchParam.Speedup=cnnp.getCC.dataTransNum;
                this.InternalArchParam.DDRBitWidth=512;
            else
                this.InternalArchParam=InternalArchParam;
            end
            this.verbose=verbose;

            if(verbose~=0)&&(verbose~=1)&&(verbose~=2)
                dnnfpga.disp(message('dnnfpga:workflow:VerboseModeToDef'));
                this.verbose=1;
            end
            this.cnnp=cnnp;

            this.fpgaParamLayers=fpgaParamLayers;
            this.hPC=hPC;
            this.frames=frames;
            this.CalData=calData;
        end
    end

    methods

        function populateNetworkLayerLatency(this)

            if isa(this.cnnp,'dnnfpga.processorbase.cnn5Processor')
                this.fpgaParamLayers=[this.fpgaParamLayers{:}];
            end

            this.filterSoftLayer;

            HWparams=this.getHWparams();
            convprocessor=this.cnnp.getConvProcessor;
            fcprocessor=this.cnnp.getFCProcessor;
            cc=this.cnnp.getCC();

            for i=1:length(this.fpgaParamLayers)
                processor=this.fpgaParamLayers{i};
                if strcmp(processor.type,'FPGA_Conv')
                    processorLayers=processor.params;
                    for j=1:length(processorLayers)
                        layer=processorLayers{j};
                        switch(layer.type)
                        case{'FPGA_Conv2D','FPGA_ConvND'}
                            Estimator=dnnfpga.estimate.EstimatorTimeConvLayer();
                            LayerResult=Estimator.GetLayerTime(convprocessor,HWparams,layer,this.InternalArchParam,this.CalData);
                            this.NetworkPerfomance(layer.phase)=LayerResult;
                        case{'FPGA_Maxpool2D','FPGA_Avgpool2D'}
                            Estimator=dnnfpga.estimate.EstimatorTimeMaxPoolLayer();
                            LayerResult=Estimator.GetLayerTime(convprocessor,HWparams,layer,this.InternalArchParam);
                            this.NetworkPerfomance(layer.phase)=LayerResult;
                        case{'FPGA_TransposedConv','FPGA_Unpool2D'}
                            Estimator=dnnfpga.estimate.EstimatorTimeUnpoolLayer();
                            LayerResult=Estimator.GetLayerTime(convprocessor,HWparams,layer,this.InternalArchParam,this.CalData);
                            this.NetworkPerfomance(layer.phase)=LayerResult;
                        case 'FPGA_Lrn2D'
                            Estimator=dnnfpga.estimate.EstimatorTimeLrnLayer();
                            LayerResult=Estimator.GetLayerTime(convprocessor,HWparams,layer,this.InternalArchParam,cc);
                            this.NetworkPerfomance(layer.phase)=LayerResult;
                        end
                    end



                elseif strcmp(processor.type,'FPGA_FC')
                    processorLayers=processor.params;
                    for k=1:length(processorLayers)
                        layer=processorLayers{k};
                        switch(layer.type)
                        case{'FPGA_FC','FPGA_GAP2D'}
                            Estimator=dnnfpga.estimate.EstimatorTimeFcLayer();
                            LayerResult=Estimator.GetLayerTime(this.hPC,fcprocessor,layer,HWparams,this.InternalArchParam,k,length(processorLayers),this.CalData);
                            this.NetworkPerfomance(layer.phase)=LayerResult;
                        case 'FPGA_Softmax'
                            Estimator=dnnfpga.estimate.EstimatorTimeSoftmaxLayer();
                            LayerResult=Estimator.GetLayerTime(this.hPC,fcprocessor,layer,HWparams,this.InternalArchParam,k,length(processorLayers),this.CalData);
                            this.NetworkPerfomance(layer.phase)=LayerResult;
                        case 'FPGA_Sigmoid'
                            Estimator=dnnfpga.estimate.EstimatorTimeSigmoidLayer();
                            LayerResult=Estimator.GetLayerTime(this.hPC,fcprocessor,layer,HWparams,this.InternalArchParam,k,length(processorLayers),this.CalData);
                            this.NetworkPerfomance(layer.phase)=LayerResult;
                        case 'FPGA_Exponential'
                            Estimator=dnnfpga.estimate.EstimatorTimeExponentialLayer();
                            LayerResult=Estimator.GetLayerTime(this.hPC,fcprocessor,layer,HWparams,this.InternalArchParam,k,length(processorLayers),this.CalData);
                            this.NetworkPerfomance(layer.phase)=LayerResult;
                        end
                    end
                elseif strcmp(processor.type,'FPGA_Adder')

                    adderProcessor=this.cnnp.getAddProcessor;
                    processorParams=processor.params;
                    dataTransNum=cc.dataTransNum;
                    layer=processorParams{1};
                    switch processor.layerClass
                    case 'nnet.cnn.layer.AdditionLayer'
                        Estimator=dnnfpga.estimate.EstimatorTimeAdder(cc.addp.SumLatency);
                    case 'nnet.internal.cnn.coder.MultiplicationLayer'
                        Estimator=dnnfpga.estimate.EstimatorTimeAdder(cc.addp.ProdLatency);
                    case 'nnet.cnn.layer.SigmoidLayer'
                        latency=cc.addp.ExpLatency+cc.addp.SingleProdLatency+cc.addp.DivideLatency+cc.addp.SumLatency;
                        Estimator=dnnfpga.estimate.EstimatorTimeAdder(latency);
                    case 'nnet.cnn.layer.TanhLayer'
                        Estimator=dnnfpga.estimate.EstimatorTimeAdder(cc.addp.TanhLatency);
                    case 'dnnfpga.layer.ExponentialLayer'
                        Estimator=dnnfpga.estimate.EstimatorTimeAdder(cc.addp.ExpLatency);
                    case 'dnnfpga.layer.identityLayer'
                        Estimator=dnnfpga.estimate.EstimatorTimeAdder(cc.addp.IdentityLatency);
                    case 'dnnfpga.custom.Resize2DLayer'



                        Estimator=dnnfpga.estimate.EstimatorTimeResize2DLayer([]);
                    end
                    LayerResult=Estimator.GetLayerTime(this.hPC,adderProcessor,layer,dataTransNum,this.CalData);
                    this.NetworkPerfomance(layer.phase)=LayerResult;
                else
                    error('This is a processor type that is not supported');
                end
            end

        end

        function NetworkTime=getNetworkTime(this)

            switch this.verbose
            case 0
                NetworkTime=this.TableBuild_verbose1();
            case 1
                NetworkTime=this.TableBuild_verbose1();
            case 2
                NetworkTime=this.TableBuild_verbose2();
            case 3
                error('mode 3 is under developing');
            end
        end

        function PerfomanceTable=TableBuild_verbose1(this)
            moduleName=this.hPC.getModuleIDList;
            [ProcessorsCycles,ModuleList]=this.getProcessorsCycles;
            NetworkLatency=0;
            freq=this.hPC.TargetFrequency;
            RowNames={'Network'};
            Latency=[];

            convModuleLatency=0;
            fcModuleLatency=0;
            adderModuleLatency=0;


            for i=1:length(ProcessorsCycles)
                processor=this.fpgaParamLayers{i};
                ProcessorLatency=ProcessorsCycles{i};
                NetworkLatency=NetworkLatency+ProcessorLatency;

                if strcmpi(ModuleList{i},'conv')
                    convModuleLatency=convModuleLatency+ProcessorLatency;
                elseif strcmpi(ModuleList{i},'fc')
                    fcModuleLatency=fcModuleLatency+ProcessorLatency;
                elseif strcmpi(ModuleList{i},'adder')
                    adderModuleLatency=adderModuleLatency+ProcessorLatency;
                end
                if isfield(processor,'params')
                    processorLayers=processor.params;
                else
                    processorLayers={};
                end
                for j=1:length(processorLayers)
                    layerName=processorLayers{j}.phase;
                    layerLatency=this.NetworkPerfomance(layerName);
                    RowNames{end+1}=strcat('________',layerName);
                    Latency=[Latency;layerLatency.layer.LayerProcessCycle];
                end
            end

            assert(isa(NetworkLatency,'double'),...
            ['NetworkLatency is not of double datatype while displaying Performance Table. '...
            ,'This may lead to incorrect FPS values.']);

            Latency=[NetworkLatency;Latency];
            Time=Latency/freq/1e+6;
            if this.frames==1
                fps=1/(NetworkLatency/(freq*1e6));
                multiFrameLatency=NetworkLatency;
            else




                fps=1/(max(convModuleLatency+adderModuleLatency,fcModuleLatency)/(freq*1e6));
                multiFrameLatency=this.frames*max(convModuleLatency+adderModuleLatency,fcModuleLatency);
            end
            numFramesRow=strings(length(Latency),1);
            numFramesRow(1,1)=string(this.frames);

            totalLatencyRow=strings(length(Latency),1);
            totalLatencyRow(1,1)=string(multiFrameLatency);

            fpsRow=strings(length(Latency),1);
            fpsRow(1,1)=string(fps);

            PerfomanceTable=table(Latency,Time,numFramesRow,totalLatencyRow,fpsRow,'RowNames',RowNames);
            PerfomanceTable.Properties.VariableNames={'Latency(cycles)','Latency(seconds)','NumFrames','Total Latency(cycles)','Frame/s'};

            format=dnnfpga.estimate.FormatTable.getPerformanceTableFormat;
            if this.verbose~=0
                dnnfpga.estimate.FormatTable.printPerformanceTable(PerfomanceTable,format,'estimator',freq,this.frames,multiFrameLatency,fps);
            end
        end

        function PerfomanceTable=TableBuild_verbose2(this)

            PerfomanceTableBasic=this.TableBuild_verbose1;
            [ProcessorsCycles,ModuleList]=this.getProcessorsCycles;
            RowNames={};
            Latency=[];
            IPTileLatency=[];
            OPTileLatency=[];
            CoreLatency=[];

            for i=1:length(this.fpgaParamLayers)
                ProcessorName=this.fpgaParamLayers{i}.type;
                processor=this.fpgaParamLayers{i};
                processorLayers=processor.params;

                for j=1:length(processorLayers)
                    layerName=processorLayers{j}.phase;
                    layerLatency=this.NetworkPerfomance(layerName);
                    RowNames{end+1}=strcat('______',layerName);
                    Latency=[Latency;layerLatency.layer.LayerProcessCycle];

                    if strcmp(ProcessorName,'FPGA_FC')||strcmp(ProcessorName,'FPGA_Adder')
                        IPTileLatency=[IPTileLatency;layerLatency.layer.LayerInputBusrtCycle];
                        OPTileLatency=[OPTileLatency;layerLatency.layer.LayerOutputBusrtCycle];
                        CoreLatency=[CoreLatency;layerLatency.layer.LayerComputationCycle];
                    else
                        IPTileLatency=[IPTileLatency;layerLatency.firstTile.InputBusrtCycle];
                        OPTileLatency=[OPTileLatency;layerLatency.firstTile.OutputBusrtCycle];
                        CoreLatency=[CoreLatency;layerLatency.firstTile.TileComputationCycle];
                    end
                end
            end
            PerfomanceTable=table(Latency,IPTileLatency,OPTileLatency,CoreLatency,'RowNames',RowNames)
        end


        function[ProcessorsCycles,ModuleList]=getProcessorsCycles(this)

            ProcessorsCycles={};
            ModuleList={};
            for i=1:length(this.fpgaParamLayers)
                processor=this.fpgaParamLayers{i};
                if isfield(processor,'params')
                    ProcessorsCycle=0;
                    for j=1:length(processor.params)
                        layer=processor.params{j};
                        layerName=layer.phase;
                        layerLatency=this.NetworkPerfomance(layerName);
                        ProcessorsCycle=ProcessorsCycle+layerLatency.layer.LayerProcessCycle;
                    end
                    ProcessorsCycles{end+1}=ProcessorsCycle;
                else
                    ProcessorsCycles{end+1}=0;
                end

                processorType=lower(processor.type);
                if contains(processorType,'conv')
                    ModuleList{end+1}='conv';
                elseif contains(processorType,'fc')
                    ModuleList{end+1}='fc';
                else
                    ModuleList{end+1}='adder';
                end
            end
        end

        function HWparams=getHWparams(this)

            convModule=this.hPC.getModule('conv');
            fcModule=this.hPC.getModule('fc');
            convModule.ShowHidden=true;
            fcModule.ShowHidden=true;

            HWparams.dataType=this.hPC.ProcessorDataType;
            HWparams.freq=this.hPC.TargetFrequency;
            HWparams.ConvThreadNumber=sqrt(convModule.ConvThreadNumber);
            HWparams.FcThreadNumber=fcModule.FCThreadNumber;
            HWparams.TargetPlatform=this.hPC.SynthesisToolChipFamily;
            HWparams.TargetFrequency=this.hPC.TargetFrequency;
            if(strcmp(HWparams.dataType,'single'))
                HWparams.dataType=32;
            elseif(strcmp(HWparams.dataType,'half'))
                HWparams.dataType=16;
            else

                HWparams.dataType=8;
            end
        end

        function filterSoftLayer(this)
            fpgaParamLayersFiltered={};
            for i=1:length(this.fpgaParamLayers)
                if strcmp(this.fpgaParamLayers{i}.type,'SW_SeriesNetwork')||strcmp(this.fpgaParamLayers{i}.type,'SW_SeriesNetwork2FPGA')||strcmp(this.fpgaParamLayers{i}.type,'SW_FPGA2SeriesNetwork')
                    continue;
                else
                    fpgaParamLayersFiltered{end+1}=this.fpgaParamLayers{i};
                end
            end
            this.fpgaParamLayers=fpgaParamLayersFiltered;
        end

    end
end


