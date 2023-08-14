classdef ProfileLogsFcp<handle








    properties
NetworkEvents
layers
verbose

        FcpLayers={}


        Fc_IP_Start={};
        Fc_IP_Done={};
        Fc_FC_Start={};
        Fc_FC_Done={};
        Fc_OP_Start={};
        Fc_OP_Done={};


        Fc_Processor_Done={};
    end

    methods
        function this=ProfileLogsFcp(cnnLogs,NetworkEvents,layers,verbose,removeExtra)
            if nargin<5
                removeExtra=true;
            end
            this.NetworkEvents=NetworkEvents;
            this.layers=layers;
            this.verbose=verbose;
            switch this.verbose
            case{1,2,3}
                this.Fc_IP_Start=cnnLogs('fc_ip_start');
                this.Fc_IP_Done=cnnLogs('fc_ip_done');
                this.Fc_FC_Start=cnnLogs('fc_fc_start');
                this.Fc_FC_Done=cnnLogs('fc_fc_done');
                this.Fc_OP_Start=cnnLogs('fc_op_start');
                this.Fc_OP_Done=cnnLogs('fc_op_done');
                this.Fc_Processor_Done=cnnLogs('fc_op_done');
            end
            if~removeExtra
                return;
            end




            if length(this.Fc_IP_Start)>1
                this.Fc_IP_Start={this.Fc_IP_Start{end}};
            end
            if length(this.Fc_IP_Done)>1
                this.Fc_IP_Done={this.Fc_IP_Done{end}};
            end




            Fc_FC_Start={};
            for i=1:length(this.Fc_FC_Start)
                if this.Fc_FC_Start{i}<this.Fc_IP_Done{end}
                    continue;
                end
                Fc_FC_Start=[Fc_FC_Start,this.Fc_FC_Start{i}];
            end
            this.Fc_FC_Start=Fc_FC_Start;
            Fc_FC_Done={};
            for i=1:length(this.Fc_FC_Start)
                offset=length(this.Fc_FC_Done)-length(this.Fc_FC_Start);
                Fc_FC_Done=[Fc_FC_Done,this.Fc_FC_Done{offset+i}];
            end
            this.Fc_FC_Done=Fc_FC_Done;



            if length(this.Fc_OP_Start)>1
                this.Fc_OP_Start={this.Fc_OP_Start{end}};
            end
            if length(this.Fc_OP_Done)>1
                this.Fc_OP_Done={this.Fc_OP_Done{end}};
            end
            if length(this.Fc_Processor_Done)>1
                this.Fc_Processor_Done={this.Fc_Processor_Done{end}};
            end
        end
    end

    methods

        function ProcessorCycle=getProcessorCycle(this)
            switch this.verbose
            case{1,2,3}

                ProcessorCycle=this.getProcessorCycleVerbose_1;
            end
        end

    end

    methods
        function ProcessorCycle=getProcessorCycleVerbose_1(this)

            firstLayer=this.FcpLayers{1};
            lastLayer=this.FcpLayers{length(this.layers)};
            ProcessorCycle=lastLayer.getLayerEnd-firstLayer.getLayerStart;
        end
    end

end

