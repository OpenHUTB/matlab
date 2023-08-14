classdef ProfileLogsConvpDAG<dnnfpga.profiler.ProfileLogsConvp











    properties
ConvLogs
    end

    methods
        function this=ProfileLogsConvpDAG(cnnLogs,NetworkEvents,layers,verbose)
            this@dnnfpga.profiler.ProfileLogsConvp(cnnLogs,NetworkEvents,layers,verbose);
            this.ConvLogs=cnnLogs;
        end
    end


    methods

        function populateConvpLayers(this)
            switch this.verbose
            case 1

                this.populateConvpLayersVerbose_1;
            case 2

                this.populateConvpLayersVerbose_2;
            case 3

                this.populateConvpLayersVerbose_3;
            end









            this.ProcessorCycle=this.Conv_ProcessorDone{1}-this.Conv_ProcessorStart{1};
            this.Conv_ProcessorStart(1)=[];
            this.Conv_ProcessorDone(1)=[];
            this.ConvLogs('conv_processorstart')=this.Conv_ProcessorStart;
            this.ConvLogs('conv_processordone')=this.Conv_ProcessorDone;
        end


        function populateConvpLayersVerbose_1(this)




            for i=1:length(this.layers)

                layerName=this.layers{i}.phase;
                layerType=this.layers{i}.type;
                switch layerType

                case{'FPGA_Conv2D','FPGA_ConvND','FPGA_Unpool2D','FPGA_TransposedConv'}
                    hConvpLayer=dnnfpga.profiler.ProfileLogsConvLayer(layerName,this.verbose);
                    LayerEvent=this.getLogCategoryStackVerbose_1;
                    hConvpLayer.addLayerEvent(LayerEvent);
                case{'FPGA_Maxpool2D','FPGA_Avgpool2D'}
                    hConvpLayer=dnnfpga.profiler.ProfileLogsMaxPoolLayer(layerName,this.verbose);
                    LayerEvent=this.getLogCategoryStackVerbose_1;
                    hConvpLayer.addLayerEvent(LayerEvent);
                case 'FPGA_Lrn2D'
                    hConvpLayer=dnnfpga.profiler.ProfileLogsLrnLayer(layerName,this.verbose);
                    LayerEvent=this.getLogCategoryStackVerbose_1;
                    hConvpLayer.addLayerEvent(LayerEvent);
                end
                this.ConvpLayers{end+1}=hConvpLayer;
            end
            this.lastFrame=this.lastFrame+1;
        end

        function LayerEvent=getLogCategoryStackVerbose_1(this)

            LayerEvent=getLogCategoryStackVerbose_1@dnnfpga.profiler.ProfileLogsConvp(this);


            this.ConvLogs('conv_layerstart')=this.Conv_LayerStart;
            this.ConvLogs('conv_layerdone')=this.Conv_LayerDone;
        end
    end

    methods

        function populateConvpLayersVerbose_2(this)





            for i=1:length(this.layers)
                layerName=this.layers{i}.phase;
                layerType=this.layers{i}.type;
                switch layerType


                case{'FPGA_Conv2D','FPGA_ConvND','FPGA_Unpool2D','FPGA_TransposedConv'}
                    hConvpLayer=dnnfpga.profiler.ProfileLogsConvLayer(layerName,this.verbose);
                    LayerEvent=this.getLogCategoryStackVerbose_1;
                    hConvpLayer.addLayerEvent(LayerEvent);
                    layerData=this.NetworkEvents(layerName);
                    TileIDList=keys(layerData);
                    for j=1:length(TileIDList)
                        TileInfo=layerData(string(j));
                        TileEvent=this.getLogCategoryStackVerbose_2(TileInfo);

                        hTile=dnnfpga.profiler.ProfileLogsTile(layerName,TileInfo,TileEvent);
                        hConvpLayer.addTiles(hTile);
                    end
                case{'FPGA_Maxpool2D','FPGA_Avgpool2D'}
                    hConvpLayer=dnnfpga.profiler.ProfileLogsMaxPoolLayer(layerName,this.verbose);
                    LayerEvent=this.getLogCategoryStackVerbose_1;
                    hConvpLayer.addLayerEvent(LayerEvent);
                    layerData=this.NetworkEvents(layerName);
                    TileIDList=keys(layerData);
                    for j=1:length(TileIDList)
                        TileInfo=layerData(string(j));
                        TileEvent=this.getLogCategoryStackVerbose_2(TileInfo);

                        hTile=dnnfpga.profiler.ProfileLogsTile(layerName,TileInfo,TileEvent);
                        hConvpLayer.addTiles(hTile);
                    end
                case 'FPGA_Lrn2D'
                    hConvpLayer=dnnfpga.profiler.ProfileLogsLrnLayer(layerName,this.verbose);
                    LayerEvent=this.getLogCategoryStackVerbose_1;
                    hConvpLayer.addLayerEvent(LayerEvent);
                    layerData=this.NetworkEvents(layerName);
                    TileIDList=keys(layerData);
                    for j=1:length(TileIDList)
                        TileInfo=layerData(string(j));
                        TileEvent=this.getLogCategoryStackVerbose_2(TileInfo);

                        hTile=dnnfpga.profiler.ProfileLogsTile(layerName,TileInfo,TileEvent);
                        hConvpLayer.addTiles(hTile);
                    end

                end
                this.ConvpLayers{end+1}=hConvpLayer;
            end
            this.lastFrame=this.lastFrame+1;
        end

        function TileEvent=getLogCategoryStackVerbose_2(this,TileInfo)

            TileEvent=getLogCategoryStackVerbose_2@dnnfpga.profiler.ProfileLogsConvp(this,TileInfo);


            this.ConvLogs('conv_ip_tilestart')=this.Conv_IP_TileStart;
            this.ConvLogs('conv_ip_tiledone')=this.Conv_IP_TileDone;
            this.ConvLogs('conv_conv_start')=this.Conv_Conv_start;
            this.ConvLogs('conv_conv_done')=this.Conv_Conv_done;
            this.ConvLogs('conv_op_tilestart')=this.Conv_OP_TileStart;
            this.ConvLogs('conv_op_tiledone')=this.Conv_OP_TileDone;
        end
    end

    methods

        function populateConvpLayersVerbose_3(this)





            for i=1:length(this.layers)
                layerName=this.layers{i}.phase;
                layerType=this.layers{i}.type;
                switch layerType

                case{'FPGA_Conv2D','FPGA_ConvND'}
                    hConvpLayer=dnnfpga.profiler.ProfileLogsConvLayer(layerName,this.verbose);
                    LayerEvent=this.getLogCategoryStackVerbose_1;
                    hConvpLayer.addLayerEvent(LayerEvent);
                    layerData=this.NetworkEvents(layerName);
                    TileIDList=keys(layerData);
                    for j=1:length(TileIDList)
                        TileInfo=layerData(string(j));
                        TileEvent=this.getLogCategoryStackVerbose_3(TileInfo);

                        hTile=dnnfpga.profiler.ProfileLogsTile(layerName,TileInfo,TileEvent);
                        hConvpLayer.addTiles(hTile);
                    end
                case{'FPGA_Maxpool2D','FPGA_Avgpool2D'}
                    hConvpLayer=dnnfpga.profiler.ProfileLogsMaxPoolLayer(layerName,this.verbose);
                    LayerEvent=this.getLogCategoryStackVerbose_1;
                    hConvpLayer.addLayerEvent(LayerEvent);
                    layerData=this.NetworkEvents(layerName);
                    TileIDList=keys(layerData);
                    for j=1:length(TileIDList)
                        TileInfo=layerData(string(j));
                        TileEvent=this.getLogCategoryStackVerbose_3(TileInfo);

                        hTile=dnnfpga.profiler.ProfileLogsTile(layerName,TileInfo,TileEvent);
                        hConvpLayer.addTiles(hTile);
                    end
                case 'FPGA_Lrn'
                    hConvpLayer=dnnfpga.profiler.ProfileLogsLrnLayer(layerName,this.verbose);
                    LayerEvent=this.getLogCategoryStackVerbose_1;
                    hConvpLayer.addLayerEvent(LayerEvent);
                    layerData=this.NetworkEvents(layerName);
                    TileIDList=keys(layerData);
                    for j=1:length(TileIDList)
                        TileInfo=layerData(string(j));
                        TileEvent=this.getLogCategoryStackVerbose_3(TileInfo);

                        hTile=dnnfpga.profiler.ProfileLogsTile(layerName,TileInfo,TileEvent);
                        hConvpLayer.addTiles(hTile);
                    end

                end
                this.ConvpLayers{end+1}=hConvpLayer;
            end
            this.lastFrame=this.lastFrame+1;
        end


        function TileEvent=getLogCategoryStackVerbose_3(this,TileInfo)

            TileEvent=getLogCategoryStackVerbose_3@dnnfpga.profiler.ProfileLogsConvp(this,TileInfo);


            this.ConvLogs('conv_ip_start')=this.Conv_IP_start;
            this.ConvLogs('conv_ip_done')=this.Conv_IP_done;
            this.ConvLogs('conv_conv_start')=this.Conv_Conv_start;
            this.ConvLogs('conv_conv_done')=this.Conv_Conv_done;
            this.ConvLogs('conv_op_start')=this.Conv_OP_start;
            this.ConvLogs('conv_op_done')=this.Conv_OP_done;
        end
    end


end

