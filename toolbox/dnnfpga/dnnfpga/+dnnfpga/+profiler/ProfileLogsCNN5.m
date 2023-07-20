classdef ProfileLogsCNN5<dnnfpga.profiler.ProfileLogsCNN4


    properties
LogCategory
ComponentLatency
    end

    methods

        function this=ProfileLogsCNN5(rawlogs,supportedEvents,fpgaLayerParams,cnnp,hPC,verbose,numFrames,logCategory)
            this@dnnfpga.profiler.ProfileLogsCNN4(rawlogs,supportedEvents,fpgaLayerParams,cnnp,hPC,verbose,numFrames);
            this.rawlogs=rawlogs;
            this.supportedEvents=supportedEvents;
            this.fpgaLayerParams=fpgaLayerParams;
            this.cnnp=cnnp;
            this.hPC=hPC;
            this.verbose=verbose;
            this.frames=numFrames;
            this.LogCategory=logCategory;
        end

        function CNNLogCategory=populateCNN4ProfilerData(this)





            [NetworkParams,NetworkEvents]=this.getNetworkInfo;



            CNNLogCategory=this.LogCategory;



            for i=1:length(NetworkParams)

                layers=NetworkParams{i}.params;
                switch NetworkParams{i}.type
                case 'FPGA_Conv'


                    hProcessor=dnnfpga.profiler.ProfileLogsConvpDAG(CNNLogCategory('conv'),NetworkEvents,layers,this.verbose);
                    hProcessor.populateConvpLayers;
                    CNNLogCategory('conv')=hProcessor.ConvLogs;
                case 'FPGA_FC'

                    hProcessor=dnnfpga.profiler.ProfileLogsFCDAG(CNNLogCategory('fc'),NetworkEvents,layers,this.verbose);
                    hProcessor.populateFcpLayers;
                    CNNLogCategory('fc')=hProcessor.FCLogs;
                case 'FPGA_Adder'

                    hProcessor=dnnfpga.profiler.ProfileLogsAdder(CNNLogCategory('adder'),NetworkEvents,layers,this.verbose);
                    CNNLogCategory('adder')=hProcessor.populateAdderLayer;
                otherwise
                    fprintf('software layer is not profiled\n');
                end

                this.CNN4ProfilerData{end+1}=hProcessor;
            end
        end

        function CNN4PerformanceTable=getCNN4PerformanceTable(this)


            ProcessorsCycles=this.getProcessorsCycles;
            CNN4LayersCycles=this.getLayersCycles;
            switch this.verbose
            case 1
                CNN4PerformanceTable=this.getCNN4PerformanceVerbose_1(ProcessorsCycles,CNN4LayersCycles);
            case 2
                CNN4PerformanceTable=this.getCNN4PerformanceVerbose_2(ProcessorsCycles,CNN4LayersCycles);
            case 3
                CNN4PerformanceTable=this.getCNN4PerformanceVerbose_3(ProcessorsCycles,CNN4LayersCycles);
            end
        end





        function CNN4PerformanceTable=getCNN4PerformanceVerbose_1(this,ProcessorsCycles,CNN4LayersCycles)


            freq=this.hPC.TargetFrequency;
            RowNames={};
            Latency=[];
            NetworkLatency=0;
            for i=1:length(this.fpgaLayerParams)

                ProcessorLatency=ProcessorsCycles{i};
                NetworkLatency=NetworkLatency+ProcessorLatency;
                LayersCycles=CNN4LayersCycles{i};
                for j=1:length(this.fpgaLayerParams{i}.params)

                    layerName=this.fpgaLayerParams{i}.params{j}.phase;
                    layerLatency=LayersCycles{j};
                    RowNames{end+1}=strcat('____',layerName);%#ok<AGROW>
                    Latency=[Latency;layerLatency.layerLatency];%#ok<AGROW>
                end
            end
            Time=Latency/freq/1e+6;
            numFramesRow=strings(length(Latency),1);
            totalLatencyRow=strings(length(Latency),1);
            fpsRow=strings(length(Latency),1);


            this.ComponentLatency=NetworkLatency;


            CNN4PerformanceTable=table(Latency,Time,numFramesRow,totalLatencyRow,fpsRow,'RowNames',RowNames);
            CNN4PerformanceTable.Properties.VariableNames={'Latency(cycles)','Latency(seconds)','NumFrames','Total Latency(cycles)','Frame/s'};
        end

        function printBasicPerformanceTable(~,~,~)





        end




        function CNN4PerformanceTable=getCNN4PerformanceVerbose_2(this,ProcessorsCycles,CNN4LayersCycles)


            rowNames={};
            totalLatency=[];
            compLatency=[];
            dataTransferPercentage=[];
            IPLatency=[];
            OPLatency=[];
            tileSize=string.empty;




            for i=1:length(this.fpgaLayerParams)
                ProcessorName=this.fpgaLayerParams{i}.type;
                ProcessorLayerCycles=CNN4LayersCycles{i};
                if strcmp(ProcessorName,'FPGA_FC')
                    for j=1:length(this.fpgaLayerParams{i}.params)
                        layerName=this.fpgaLayerParams{i}.params{j}.frontendLayers{1};
                        layerDetails=ProcessorLayerCycles{j};
                        rowNames{end+1}=layerName;%#ok<AGROW>
                        totalLatency=[totalLatency;layerDetails.layerLatency];%#ok<AGROW>
                        IPLatency=[IPLatency;layerDetails.input];%#ok<AGROW>
                        OPLatency=[OPLatency;layerDetails.output];%#ok<AGROW>
                        compLatency=[compLatency;layerDetails.compute];%#ok<AGROW>
                        tileSize=[tileSize;" "];%#ok<AGROW>
                        calculatedPercentageNumber=(layerDetails.input+layerDetails.output)/layerDetails.compute;
                        dataTransferPercentage=[dataTransferPercentage;calculatedPercentageNumber];%#ok<AGROW>
                    end
                elseif strcmp(ProcessorName,'FPGA_Adder')
















                elseif strcmp(ProcessorName,'FPGA_Conv')
                    for j=1:length(this.fpgaLayerParams{i}.params)
                        layerName=this.fpgaLayerParams{i}.params{j}.frontendLayers{1};
                        layerDetails=ProcessorLayerCycles{j};
                        rowNames{end+1}=layerName;%#ok<AGROW>
                        totalLatency=[totalLatency;layerDetails.layerLatency];%#ok<AGROW>
                        IPLatency=[IPLatency;layerDetails.IPTileLatency];%#ok<AGROW> % TileLatency
                        OPLatency=[OPLatency;layerDetails.OPTileLatency];%#ok<AGROW> % TileLatency
                        compLatency=[compLatency;layerDetails.ConvLatency];%#ok<AGROW>
                        tileSize=[tileSize;num2str(layerDetails.ConvTileSize)];%#ok<AGROW>
                        calculatedPercentageNumber=(layerDetails.IPTileLatency+layerDetails.OPTileLatency)/layerDetails.ConvLatency;
                        dataTransferPercentage=[dataTransferPercentage;calculatedPercentageNumber];%#ok<AGROW>
                    end
                else

                    printString=sprintf('Unexpected ProcessorName %s.',ProcessorName);
                    error(printString);
                end
                CNN4PerformanceTable=table(totalLatency,IPLatency,OPLatency,compLatency,dataTransferPercentage,tileSize,'RowNames',rowNames)
            end

        end


    end

    methods(Static=true)

        function pLogs=getDAGNetPerformanceTable(rawLogs,supportedEvents,cnnp,hPC,verbose,numFrames,fpgaLayerParams,displayTable)
            mapper=dnnfpga.profiler.ProfileLogsRawDataSplitCNN5(rawLogs.eventAndTimeStamp,supportedEvents,verbose);
            if verbose>1

                dnnfpga.profiler.ProfileLogsCNN5.emitPerformanceTable(...
                rawLogs,supportedEvents,cnnp,hPC,1,numFrames,fpgaLayerParams,mapper,displayTable);
            end

            pLogs=dnnfpga.profiler.ProfileLogsCNN5.emitPerformanceTable(...
            rawLogs,supportedEvents,cnnp,hPC,verbose,numFrames,fpgaLayerParams,mapper,displayTable);
        end

        function pLogs=emitPerformanceTable(rawLogs,supportedEvents,cnnp,hPC,verbose,numFrames,fpgaLayerParams,mapper,displayTable)
            pLogs=[];
            logCategory=mapper.getMappedLogs;
            sortedComponents=fpgaLayerParams.sortedComponents';
            networkLatency=0;
            for component=sortedComponents





                legLevelIR=component.LegLevelIR;
                if isempty(legLevelIR)
                    continue;
                end
                hCNN5=dnnfpga.profiler.ProfileLogsCNN5(rawLogs.eventAndTimeStamp,supportedEvents,legLevelIR,cnnp,hPC,verbose,numFrames,logCategory);
                logCategory=hCNN5.populateCNN4ProfilerData();
                pLogs=[pLogs;hCNN5.getCNN4PerformanceTable];%#ok<AGROW>
                networkLatency=networkLatency+hCNN5.ComponentLatency;
            end



            if verbose==1

                freq=hPC.TargetFrequency;
                networkName={'Network'};
                networkLatencyCycles=networkLatency;
                networkLatencySeconds=networkLatencyCycles/freq/10^6;


                multiFrameTotalLatency=double(rawLogs.totalExecutionTime);
                framePerSecond=numFrames*(freq*1e6)/multiFrameTotalLatency;

                networkTable=table(networkLatencyCycles,networkLatencySeconds,numFrames,multiFrameTotalLatency,framePerSecond,'RowNames',networkName);
                networkTable.Properties.VariableNames={'Latency(cycles)','Latency(seconds)','NumFrames','Total Latency(cycles)','Frame/s'};
                networkTable=[networkTable;pLogs];
                pLogs=networkTable;


                if displayTable

                    format=dnnfpga.estimate.FormatTable.getPerformanceTableFormat;
                    dnnfpga.estimate.FormatTable.printPerformanceTable(pLogs,format,'profiler',freq,numFrames,multiFrameTotalLatency,framePerSecond);
                end
            end

        end

    end
end

