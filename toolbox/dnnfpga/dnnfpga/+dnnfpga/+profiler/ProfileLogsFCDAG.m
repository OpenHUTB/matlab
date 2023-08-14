classdef ProfileLogsFCDAG<dnnfpga.profiler.ProfileLogsFcp








    properties
FCLogs
    end

    methods

        function this=ProfileLogsFCDAG(cnnLogs,NetworkEvents,layers,verbose)
            this@dnnfpga.profiler.ProfileLogsFcp(cnnLogs,NetworkEvents,layers,verbose,false);
            switch this.verbose
            case{1,2,3}
                this.FCLogs=cnnLogs;
            end

        end

    end

    methods

        function populateFcpLayers(this)
            switch this.verbose
            case{1,2,3}

                this.populateFcpLayersVerbose_1;
            end
        end

        function ProcessorLayersCycles=getLayersCycles(this)

            ProcessorLayersCycles=this.getLayersCyclesVerbose;
        end

        function populateFcpLayersVerbose_1(this)


            for i=1:length(this.layers)
                layerName=this.layers{i}.frontendLayers{1};
                layerType=this.layers{i}.type;
                switch layerType

                case{'FPGA_FC','FPGA_GAP2D','FPGA_Softmax','FPGA_Sigmoid','FPGA_Exponential'}
                    hFcLayer=dnnfpga.profiler.ProfileLogsFcLayer(layerName,i,length(this.layers),this.verbose);
                    LayerEvent=this.getLogCategoryStackVerbose_1(length(this.layers),i);
                    hFcLayer.addLayerEvent(LayerEvent);
                end
                this.FcpLayers{end+1}=hFcLayer;
            end
        end


        function LayerEvent=getLogCategoryStackVerbose_1(this,layerNum,layerIndex)



            LayerEvent.Fc_FC_Start=this.Fc_FC_Start{1};
            LayerEvent.Fc_FC_Done=this.Fc_FC_Done{1};
            this.Fc_FC_Start(1)=[];
            this.Fc_FC_Done(1)=[];


            this.FCLogs('fc_fc_start')=this.Fc_FC_Start;
            this.FCLogs('fc_fc_done')=this.Fc_FC_Done;

            if(layerIndex==1)
                LayerEvent.Fc_IP_Start=this.Fc_IP_Start{1};
                LayerEvent.Fc_IP_Done=this.Fc_IP_Done{1};
                this.Fc_IP_Start(1)=[];
                this.Fc_IP_Done(1)=[];


                this.FCLogs('fc_ip_start')=this.Fc_IP_Start;
                this.FCLogs('fc_ip_done')=this.Fc_IP_Start;

            else
                LayerEvent.Fc_IP_Start=[];
                LayerEvent.Fc_IP_Done=[];
            end

            if(layerIndex==layerNum)
                LayerEvent.Fc_OP_Start=this.Fc_OP_Start{1};
                LayerEvent.Fc_OP_Done=this.Fc_OP_Done{1};
                this.Fc_OP_Start(1)=[];
                this.Fc_OP_Done(1)=[];


                this.FCLogs('fc_op_start')=this.Fc_OP_Start;
                this.FCLogs('fc_op_done')=this.Fc_OP_Done;

            else
                LayerEvent.Fc_OP_Start=[];
                LayerEvent.Fc_OP_Done=[];
            end
        end
    end

    methods


        function ProcessorDoneTime=getProcessorDoneTime(this)
            ProcessorDoneTime=this.Fc_Processor_Done{1};
        end

        function ProcessorLayersCycles=getLayersCyclesVerbose(this)

            ProcessorLayersCycles={};
            for i=1:length(this.layers)
                layer=this.FcpLayers{i};
                LayerCycle=layer.getLayerCycle;
                ProcessorLayersCycles{end+1}=LayerCycle;
            end
        end
    end

end

