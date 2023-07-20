classdef ProfileLogsConvp<handle








    properties
NetworkEvents
layers

        lastFrame=0
verbose

        ConvpLayers={}


        Conv_LayerStart={}
        Conv_LayerDone={}
        Conv_ProcessorStart={}
        Conv_ProcessorDone={}

        Conv_IP_TileStart={}
        Conv_IP_TileDone={}
        Conv_OP_TileStart={}
        Conv_OP_TileDone={}
        Conv_Conv_start={}
        Conv_Conv_done={}

        Conv_IP_start={}
        Conv_IP_done={}
        Conv_OP_start={}
        Conv_OP_done={}


        ProcessorCycle=[]

    end

    methods
        function this=ProfileLogsConvp(cnnLogs,NetworkEvents,layers,verbose)
            this.NetworkEvents=NetworkEvents;
            this.layers=layers;
            this.verbose=verbose;
            switch this.verbose
            case 1
                this.Conv_ProcessorStart=cnnLogs('conv_processorstart');
                this.Conv_ProcessorDone=cnnLogs('conv_processordone');
                this.Conv_LayerStart=cnnLogs('conv_layerstart');
                this.Conv_LayerDone=cnnLogs('conv_layerdone');
            case 3
                this.Conv_ProcessorStart=cnnLogs('conv_processorstart');
                this.Conv_ProcessorDone=cnnLogs('conv_processordone');
                this.Conv_LayerStart=cnnLogs('conv_layerstart');
                this.Conv_LayerDone=cnnLogs('conv_layerdone');
                this.Conv_IP_start=cnnLogs('conv_ip_start');
                this.Conv_IP_done=cnnLogs('conv_ip_done');
                this.Conv_Conv_start=cnnLogs('conv_conv_start');
                this.Conv_Conv_done=cnnLogs('conv_conv_done');
                this.Conv_OP_start=cnnLogs('conv_op_start');
                this.Conv_OP_done=cnnLogs('conv_op_done');
            case 2
                this.Conv_ProcessorStart=cnnLogs('conv_processorstart');
                this.Conv_ProcessorDone=cnnLogs('conv_processordone');
                this.Conv_LayerStart=cnnLogs('conv_layerstart');
                this.Conv_LayerDone=cnnLogs('conv_layerdone');
                this.Conv_IP_TileStart=cnnLogs('conv_ip_tilestart');
                this.Conv_IP_TileDone=cnnLogs('conv_ip_tiledone');
                this.Conv_Conv_start=cnnLogs('conv_conv_start');
                this.Conv_Conv_done=cnnLogs('conv_conv_done');
                this.Conv_OP_TileStart=cnnLogs('conv_op_tilestart');
                this.Conv_OP_TileDone=cnnLogs('conv_op_tiledone');
            end
        end
    end

    methods

        function ProcessorCycle=getProcessorCycle(this)

            ProcessorCycle=this.getProcessorCycleVerbose;
        end


        function ProcessorLayersCycles=getLayersCycles(this)

            ProcessorLayersCycles=this.getLayersCyclesVerbose;
        end
    end

    methods

        function LayerEvent=getLogCategoryStackVerbose_1(this)



            LayerEvent.Conv_LayerStart=this.Conv_LayerStart{1};
            LayerEvent.Conv_LayerDone=this.Conv_LayerDone{1};

            this.Conv_LayerStart(1)=[];
            this.Conv_LayerDone(1)=[];
        end
    end

    methods

        function TileEvent=getLogCategoryStackVerbose_2(this,TileInfo)



            TileEvent.Conv_IP_TileStart=this.Conv_IP_TileStart(1);
            TileEvent.Conv_IP_TileDone=this.Conv_IP_TileDone(1);
            TileEvent.Conv_OP_TileStart=this.Conv_OP_TileStart(1);
            TileEvent.Conv_OP_TileDone=this.Conv_OP_TileDone(1);
            TileEvent.Conv_Conv_start=this.Conv_Conv_start(1:(TileInfo.conv/2));
            TileEvent.Conv_Conv_done=this.Conv_Conv_done(1:(TileInfo.conv/2));


            this.Conv_IP_TileStart(1)=[];
            this.Conv_IP_TileDone(1)=[];
            this.Conv_Conv_start(1:(TileInfo.conv/2))=[];
            this.Conv_Conv_done(1:(TileInfo.conv/2))=[];
            this.Conv_OP_TileStart(1)=[];
            this.Conv_OP_TileDone(1)=[];
        end
    end

    methods
        function TileEvent=getLogCategoryStackVerbose_3(this,TileInfo)



            TileEvent.Conv_IP_start=this.Conv_IP_start(1:(TileInfo.input/2));
            TileEvent.Conv_IP_done=this.Conv_IP_done(1:(TileInfo.input/2));
            TileEvent.Conv_Conv_start=this.Conv_Conv_start(1:(TileInfo.conv/2));
            TileEvent.Conv_Conv_done=this.Conv_Conv_done(1:(TileInfo.conv/2));
            TileEvent.Conv_OP_start=this.Conv_OP_start(1:(TileInfo.output/2));
            TileEvent.Conv_OP_done=this.Conv_OP_done(1:(TileInfo.output/2));

            this.Conv_IP_start(1:(TileInfo.input/2))=[];
            this.Conv_IP_done(1:(TileInfo.input/2))=[];
            this.Conv_Conv_start(1:(TileInfo.conv/2))=[];
            this.Conv_Conv_done(1:(TileInfo.conv/2))=[];
            this.Conv_OP_start(1:(TileInfo.output/2))=[];
            this.Conv_OP_done(1:(TileInfo.output/2))=[];
        end
    end

    methods


        function ProcessorCycle=getProcessorCycleVerbose(this)


            ProcessorCycle=this.ProcessorCycle;
        end

        function ProcessorLayersCycles=getLayersCyclesVerbose(this)

            ProcessorLayersCycles={};
            for i=1:length(this.layers)
                layer=this.ConvpLayers{i};
                LayerCycle=layer.getLayerCycle;
                ProcessorLayersCycles{end+1}=LayerCycle;
            end
        end
    end

end

