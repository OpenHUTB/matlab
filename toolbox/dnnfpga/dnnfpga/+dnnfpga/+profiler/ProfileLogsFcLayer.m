classdef ProfileLogsFcLayer<dnnfpga.profiler.ProfileLogsConvpLayerbase






    properties
layerName
layerIndex
layerNum
verbose
layerInfo
layerEvent
    end

    methods
        function this=ProfileLogsFcLayer(layerName,layerIndex,layerNum,verbose)
            this.verbose=verbose;
            this.layerIndex=layerIndex;
            this.layerNum=layerNum;
            this.layerName=layerName;
        end
    end

    methods
        function LayerCycle=getLayerCycle(this)
            switch this.verbose
            case{1}
                LayerCycle=this.getLayerCycleVerbose_1;
            case{2,3}
                LayerCycle=this.getLayerCycleVerbose_23;
            end
        end


        function LayerStart=getLayerStart(this)
            switch this.verbose
            case{1,2,3}
                LayerStart=this.getLayerStartVerbose_1;
            end
        end

        function LayerEnd=getLayerEnd(this)
            switch this.verbose
            case{1,2,3}
                LayerEnd=this.getLayerEndVerbose_1;
            end
        end
    end

    methods
        function addLayerEvent(this,layerEvent)

            this.layerEvent=layerEvent;
        end

        function layerDetails=getLayerCycleVerbose_1(this)

            if(this.layerIndex==this.layerNum&&this.layerNum==1)
                layerDetails.layerLatency=this.layerEvent.Fc_OP_Done-this.layerEvent.Fc_IP_Start;

            elseif(this.layerIndex<this.layerNum&&this.layerIndex==1)
                layerDetails.layerLatency=this.layerEvent.Fc_FC_Done-this.layerEvent.Fc_IP_Start;

            elseif(this.layerIndex<this.layerNum&&this.layerIndex>1)
                layerDetails.layerLatency=this.layerEvent.Fc_FC_Done-this.layerEvent.Fc_FC_Start;

            elseif(this.layerIndex==this.layerNum&&this.layerIndex>1)
                layerDetails.layerLatency=this.layerEvent.Fc_OP_Done-this.layerEvent.Fc_FC_Start;
            end
        end

        function layerDetails=getLayerCycleVerbose_23(this)

            if(this.layerIndex==this.layerNum&&this.layerNum==1)
                layerDetails.layerLatency=this.layerEvent.Fc_OP_Done-this.layerEvent.Fc_IP_Start;
                layerDetails.input=this.layerEvent.Fc_IP_Done-this.layerEvent.Fc_IP_Start;
                layerDetails.output=this.layerEvent.Fc_OP_Done-this.layerEvent.Fc_OP_Start;
                layerDetails.compute=this.layerEvent.Fc_FC_Done-this.layerEvent.Fc_FC_Start;

            elseif(this.layerIndex<this.layerNum&&this.layerIndex==1)
                layerDetails.layerLatency=this.layerEvent.Fc_FC_Done-this.layerEvent.Fc_IP_Start;
                layerDetails.input=this.layerEvent.Fc_IP_Done-this.layerEvent.Fc_IP_Start;
                layerDetails.output=0;
                layerDetails.compute=this.layerEvent.Fc_FC_Done-this.layerEvent.Fc_FC_Start;

            elseif(this.layerIndex<this.layerNum&&this.layerIndex>1)
                layerDetails.layerLatency=this.layerEvent.Fc_FC_Done-this.layerEvent.Fc_FC_Start;
                layerDetails.input=0;
                layerDetails.output=0;
                layerDetails.compute=this.layerEvent.Fc_FC_Done-this.layerEvent.Fc_FC_Start;

            elseif(this.layerIndex==this.layerNum&&this.layerIndex>1)
                layerDetails.layerLatency=this.layerEvent.Fc_OP_Done-this.layerEvent.Fc_FC_Start;
                layerDetails.input=0;
                layerDetails.output=this.layerEvent.Fc_OP_Done-this.layerEvent.Fc_OP_Start;
                layerDetails.compute=this.layerEvent.Fc_FC_Done-this.layerEvent.Fc_FC_Start;
            end
        end

        function LayerStart=getLayerStartVerbose_1(this)

            if(this.layerIndex==1)
                LayerStart=this.layerEvent.Fc_IP_Start;

            elseif(this.layerIndex<=this.layerNum&&this.layerIndex>1)
                LayerStart=this.layerEvent.Fc_FC_Start;
            end
        end

        function LayerEnd=getLayerEndVerbose_1(this)

            if(this.layerIndex==this.layerNum)
                LayerEnd=this.layerEvent.Fc_OP_Done;

            elseif(this.layerIndex<this.layerNum)
                LayerEnd=this.layerEvent.Fc_FC_Done;
            end
        end
    end


end
