classdef ProfileLogsCNN4<handle















    properties
rawlogs
supportedEvents
fpgaLayerParams
cnnp
hPC
verbose
        CNN4ProfilerData={}



        frames=1
    end

    methods
        function this=ProfileLogsCNN4(rawlogs,supportedEvents,fpgaLayerParams,cnnp,hPC,verbose,numFrames)
            this.rawlogs=rawlogs;
            this.supportedEvents=supportedEvents;
            this.fpgaLayerParams=fpgaLayerParams;
            this.cnnp=cnnp;
            this.hPC=hPC;
            this.verbose=verbose;
            this.frames=numFrames;
        end
    end

    methods

        function ProcessorsCycles=getProcessorsCycles(this)




            ProcessorsCycles={};
            for i=1:length(this.CNN4ProfilerData)

                Processor=this.CNN4ProfilerData{i};
                ProcessorCycle=Processor.getProcessorCycle;
                ProcessorsCycles{end+1}=ProcessorCycle;
            end
        end

        function CNN4LayersCycles=getLayersCycles(this)


            CNN4LayersCycles={};
            for i=1:length(this.CNN4ProfilerData)

                Processor=this.CNN4ProfilerData{i};
                ProcessorLayersCycles=Processor.getLayersCycles;
                CNN4LayersCycles{end+1}=ProcessorLayersCycles;
            end
        end




        function CNN4PerformanceTable=getCNN4PerformanceVerbose_3(this,ProcessorsCycles,CNN4LayersCycles)

            this.printBasicPerformanceTable(ProcessorsCycles,CNN4LayersCycles);

            RowNames={};
            Latency=[];

            IPBurstLatency=[];
            IPDonetoIPStartInterval=[];
            IPtoConvInterval=[];
            ConvLatency=[];
            ConvTileSize=[];
            ConvtoOPInterval=[];
            OPDonetoOPStartInterval=[];
            OPBurstLatency=[];


            IPDataNumEachBurst=[];
            OPDataNumEachBurst=[];

            for i=1:length(this.fpgaLayerParams)
                ProcessorName=this.fpgaLayerParams{i}.type;
                if strcmp(ProcessorName,'FPGA_FC')
                    continue
                else
                    ProcessorLatency=ProcessorsCycles{i};
                    RowNames{end+1}=ProcessorName;
                    Latency=[Latency;ProcessorLatency];
                    IPBurstLatency=[IPBurstLatency;0];
                    IPDonetoIPStartInterval=[IPDonetoIPStartInterval;0];
                    IPtoConvInterval=[IPtoConvInterval;0];
                    ConvLatency=[ConvLatency;0];
                    ConvTileSize=[ConvTileSize;string('')];
                    ConvtoOPInterval=[ConvtoOPInterval;0];
                    OPDonetoOPStartInterval=[OPDonetoOPStartInterval;0];
                    OPBurstLatency=[OPBurstLatency;0];
                    IPDataNumEachBurst=[IPDataNumEachBurst;0];
                    OPDataNumEachBurst=[OPDataNumEachBurst;0];
                    ProcessorLayerCycles=CNN4LayersCycles{i};
                    for j=1:length(this.fpgaLayerParams{i}.params)

                        layerName=this.fpgaLayerParams{i}.params{j}.frontendLayers{1};
                        layerDetails=ProcessorLayerCycles{j};
                        RowNames{end+1}=strcat('______',layerName);
                        Latency=[Latency;layerDetails.layerLatency];
                        IPBurstLatency=[IPBurstLatency;layerDetails.IPBurstLatency];
                        IPtoConvInterval=[IPtoConvInterval;layerDetails.IPtoConvInterval];
                        ConvLatency=[ConvLatency;layerDetails.ConvLatency];
                        ConvTileSize=[ConvTileSize;num2str(layerDetails.ConvTileSize)];
                        ConvtoOPInterval=[ConvtoOPInterval;layerDetails.ConvtoOPInterval];
                        OPBurstLatency=[OPBurstLatency;layerDetails.OPBurstLatency];
                        IPDataNumEachBurst=[IPDataNumEachBurst;layerDetails.TileSingleIPBurstNum];
                        OPDataNumEachBurst=[OPDataNumEachBurst;layerDetails.TileSingleOPBurstNum];
                    end
                end
            end

            CNN4PerformanceTable=table(Latency,IPBurstLatency,IPDataNumEachBurst,IPtoConvInterval,...
            ConvLatency,ConvTileSize,ConvtoOPInterval,OPBurstLatency,OPDataNumEachBurst,'RowNames',RowNames)
        end

        function[NetworkParams,NetworkEvents]=getNetworkInfo(this)

            NetAnalyser=dnnfpga.profiler.ProfileLogsNetAnalysis();
            [NetworkParams,NetworkEvents]=NetAnalyser.getNetworkInfo(this.fpgaLayerParams,this.cnnp);
        end


    end

end

