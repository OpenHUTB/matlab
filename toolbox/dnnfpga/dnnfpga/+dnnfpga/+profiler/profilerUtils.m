classdef profilerUtils



    methods(Static=true)

        function supportedEvents=resolveSupportedEventsForDAGNet()

            supportedEvents=dnnfpga.profiler.abstractEvent.empty();
            CNN5supportedProfileEvents=["CONV_IP_Start","CONV_IP_Done","CONV_CONV_Start","CONV_CONV_Done",...
            "CONV_OP_Start","CONV_OP_Done","CONV_ProcessorDone",...
            "CONV_IP_TileStart","CONV_IP_TileDone",...
            "CONV_LayerStart","CONV_ProcessorStart","CONV_OP_TileStart","CONV_OP_TileDone",...
            "CONV_LayerDoneDummy","CONV_LayerDone",...
            "FC_IP_Start","FC_IP_Done",...
            "FC_FC_Start","FC_FC_Done",...
            "FC_OP_Start","FC_OP_Done",...
            "Adder_Start",...
            "Adder_IP_Start","Adder_IP_Done",...
            "Adder_OP_Start","Adder_OP_Done",...
            "Adder_Done",...
"Frame_Start"
            ];
            for profileEvent=CNN5supportedProfileEvents
                switch lower(profileEvent)
                case 'conv_ip_start'

                    supportedEvent=dnnfpga.profiler.B2ConvIPStartEvent(0,'CONV_IP_Start');
                case 'conv_ip_done'

                    supportedEvent=dnnfpga.profiler.B2ConvIPDoneEvent(1,'CONV_IP_Done');
                case 'conv_conv_start'

                    supportedEvent=dnnfpga.profiler.B2ConvStartEvent(2,'CONV_CONV_Start');
                case 'conv_conv_done'

                    supportedEvent=dnnfpga.profiler.B2ConvDoneEvent(3,'CONV_CONV_Done');
                case 'conv_op_start'

                    supportedEvent=dnnfpga.profiler.B2ConvOPStartEvent(4,'CONV_OP_Start');
                case 'conv_op_done'

                    supportedEvent=dnnfpga.profiler.B2ConvOPDoneEvent(5,'CONV_OP_Done');
                case 'conv_processordone'

                    supportedEvent=dnnfpga.profiler.B2ConvProcessorDoneEvent(6,'CONV_ProcessorDone');
                case 'conv_ip_tilestart'

                    supportedEvent=dnnfpga.profiler.B2ConvIPTileStartEvent(7,'CONV_IP_TileStart');
                case 'conv_ip_tiledone'

                    supportedEvent=dnnfpga.profiler.B2ConvIPTileDoneEvent(8,'CONV_IP_TileDone');
                case 'conv_layerstart'


                    supportedEvent=dnnfpga.profiler.B2ConvLayerStartEvent(9,'CONV_LayerStart');
                case 'conv_processorstart'
                    supportedEvent=dnnfpga.profiler.B2ConvProcessorStartEvent(10,'CONV_ProcessorStart');
                case 'conv_op_tilestart'

                    supportedEvent=dnnfpga.profiler.B2ConvOPTileStartEvent(11,'CONV_OP_TileStart');
                case 'conv_op_tiledone'

                    supportedEvent=dnnfpga.profiler.B2ConvOPTileDoneEvent(12,'CONV_OP_TileDone');
                case 'conv_layerdonedummy'
                    supportedEvent=dnnfpga.profiler.B2ConvLayerDoneEvent(13,'CONV_LayerDoneDummy');
                case 'conv_layerdone'


                    supportedEvent=dnnfpga.profiler.B2ConvLayerDoneEvent(14,'CONV_LayerDone');
                case 'fc_ip_start'

                    supportedEvent=dnnfpga.profiler.B2FcIPStartEvent(15,'FC_IP_Start');
                case 'fc_ip_done'

                    supportedEvent=dnnfpga.profiler.B2FcIPDoneEvent(16,'FC_IP_Done');
                case 'fc_fc_start'

                    supportedEvent=dnnfpga.profiler.B2FcStartEvent(17,'FC_FC_Start');
                case 'fc_fc_done'

                    supportedEvent=dnnfpga.profiler.B2FcDoneEvent(18,'FC_FC_Done');
                case 'fc_op_start'

                    supportedEvent=dnnfpga.profiler.B2FcOPStartEvent(19,'FC_OP_Start');
                case 'fc_op_done'

                    supportedEvent=dnnfpga.profiler.B2FcOPDoneEvent(20,'FC_OP_Done');
                case 'adder_start'

                    supportedEvent=dnnfpga.profiler.B2AdderStartEvent(21,'Adder_Start');
                case 'adder_ip_start'

                    supportedEvent=dnnfpga.profiler.B2AdderIPStartEvent(22,'Adder_IP_Start');
                case 'adder_ip_done'

                    supportedEvent=dnnfpga.profiler.B2AdderIPDoneEvent(23,'Adder_IP_Done');
                case 'adder_op_start'

                    supportedEvent=dnnfpga.profiler.B2AdderOPStartEvent(24,'Adder_OP_Start');
                case 'adder_op_done'

                    supportedEvent=dnnfpga.profiler.B2AdderOPDoneEvent(25,'Adder_OP_Done');
                case 'adder_done'

                    supportedEvent=dnnfpga.profiler.B2AdderDoneEvent(26,'Adder_Done');
                case 'frame_start'





                    supportedEvent=[];
                otherwise
                    assert(false,sprintf('Unknown profiler event: %s',profileEvent));
                end

                if~isempty(supportedEvent)
                    supportedEvents(end+1)=supportedEvent;%#ok<AGROW>
                end
            end
        end

    end
end
