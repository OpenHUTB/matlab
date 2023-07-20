classdef ProfileLogsRawDataSplitCNN5<dnnfpga.profiler.ProfileLogsRawDataSplit


    methods

        function this=ProfileLogsRawDataSplitCNN5(rawLogs,supportedEvents,verbose)
            this@dnnfpga.profiler.ProfileLogsRawDataSplit(rawLogs,supportedEvents,verbose);
        end
    end

    methods(Access=public)

        function cnnLogCategory=getCNNLogCategoryVerbose_1(~,eventID,timestamp,cnnevents)

            cnnLogCategory=containers.Map;
            convLogCategory=containers.Map;
            fcLogCategory=containers.Map;
            adderLogCategory=containers.Map;


            convProcessorStart={};
            convLayerStart={};
            convLayerDone={};
            convProcessorDone={};


            fcIPStart={};
            fcIPDone={};
            fcFCStart={};
            fcFCDone={};
            fcOPStart={};
            fcOPDone={};


            adderStart={};
            adderDone={};
            adderIPStart={};
            adderIPDone={};
            adderOPStart={};
            adderOPDone={};

            for i=1:length(eventID)
                eventName=strcat(lower(cnnevents(eventID(i)).getName()));
                eventTime=timestamp(i);
                switch eventName
                case 'conv_processorstart'
                    convProcessorStart{end+1}=eventTime;%#ok<AGROW>
                case 'conv_processordone'
                    convProcessorDone{end+1}=eventTime;%#ok<AGROW>
                case 'conv_layerstart'
                    convLayerStart{end+1}=eventTime;%#ok<AGROW>
                case 'conv_layerdone'
                    convLayerDone{end+1}=eventTime;%#ok<AGROW>
                case 'fc_ip_start'
                    fcIPStart{end+1}=eventTime;%#ok<AGROW>
                case 'fc_ip_done'
                    fcIPDone{end+1}=eventTime;%#ok<AGROW>
                case 'fc_fc_start'
                    fcFCStart{end+1}=eventTime;%#ok<AGROW>
                case 'fc_fc_done'
                    fcFCDone{end+1}=eventTime;%#ok<AGROW>
                case 'fc_op_start'
                    fcOPStart{end+1}=eventTime;%#ok<AGROW>
                case 'fc_op_done'
                    fcOPDone{end+1}=eventTime;%#ok<AGROW>
                case 'adder_start'
                    adderStart{end+1}=eventTime;%#ok<AGROW>
                case 'adder_done'
                    adderDone{end+1}=eventTime;%#ok<AGROW>
                case 'adder_ip_start'
                    adderIPStart{end+1}=eventTime;%#ok<AGROW>
                case 'adder_ip_done'
                    adderIPDone{end+1}=eventTime;%#ok<AGROW>  
                case 'adder_op_start'
                    adderOPStart{end+1}=eventTime;%#ok<AGROW>
                case 'adder_op_done'
                    adderOPDone{end+1}=eventTime;%#ok<AGROW>                          
                otherwise

                end
            end


            convLogCategory('conv_processorstart')=convProcessorStart;
            convLogCategory('conv_processordone')=convProcessorDone;
            convLogCategory('conv_layerstart')=convLayerStart;
            convLogCategory('conv_layerdone')=convLayerDone;


            fcLogCategory('fc_ip_start')=fcIPStart;
            fcLogCategory('fc_ip_done')=fcIPDone;
            fcLogCategory('fc_fc_start')=fcFCStart;
            fcLogCategory('fc_fc_done')=fcFCDone;
            fcLogCategory('fc_op_start')=fcOPStart;
            fcLogCategory('fc_op_done')=fcOPDone;


            adderLogCategory('adder_start')=adderStart;
            adderLogCategory('adder_done')=adderDone;
            adderLogCategory('adder_ip_start')=adderIPStart;
            adderLogCategory('adder_ip_done')=adderIPDone;
            adderLogCategory('adder_op_start')=adderOPStart;
            adderLogCategory('adder_op_done')=adderOPDone;


            cnnLogCategory('conv')=convLogCategory;
            cnnLogCategory('fc')=fcLogCategory;
            cnnLogCategory('adder')=adderLogCategory;
            cnnLogCategory('cnnevents')=cnnevents;
        end
    end

end
