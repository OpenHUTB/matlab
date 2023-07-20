classdef ProfileLogsRawDataSplit<handle




    properties(Access=private)
rawLogs
supportedEvents
verbose
    end

    methods(Access=public)

        function this=ProfileLogsRawDataSplit(rawLogs,supportedEvents,verbose)
            this.rawLogs=rawLogs;
            this.supportedEvents=supportedEvents;
            this.verbose=verbose;
        end
    end

    methods(Access=public)




        function CNNLogCategory=getMappedLogs(this)
            [eventID,timestamp]=this.parse(this.rawLogs);
            cnnevents=this.supportedEvents;
            CNNLogCategory=this.getCNNLogCategory(eventID,timestamp,cnnevents);
        end

        function CNNLogCategory=getCNNLogCategory(this,eventID,timestamp,cnnevents)



            switch this.verbose
            case 1
                CNNLogCategory=this.getCNNLogCategoryVerbose_1(eventID,timestamp,cnnevents);
            case 2
                CNNLogCategory=this.getCNNLogCategoryVerbose_2(eventID,timestamp,cnnevents);
            case 3
                CNNLogCategory=this.getCNNLogCategoryVerbose_3(eventID,timestamp,cnnevents);
            end
        end

        function CNNLogCategory=getCNNLogCategoryVerbose_2(this,eventID,timestamp,cnnevents)


            CNNLogCategory=this.getCNNLogCategoryVerbose_1(eventID,timestamp,cnnevents);
            ConvLogCategory=CNNLogCategory('conv');
            CONV_IP_TileStart={};
            CONV_IP_TileDone={};
            Conv_Conv_start={};
            Conv_Conv_done={};
            CONV_OP_TileStart={};
            CONV_OP_TileDone={};

            for i=1:length(eventID)
                eventName=strcat(lower(cnnevents(eventID(i)).getName()));
                eventTime=timestamp(i);
                switch eventName
                case 'conv_ip_tilestart'
                    CONV_IP_TileStart{end+1}=eventTime;
                case 'conv_ip_tiledone'
                    CONV_IP_TileDone{end+1}=eventTime;
                case 'conv_conv_start'
                    Conv_Conv_start{end+1}=eventTime;
                case 'conv_conv_done'
                    Conv_Conv_done{end+1}=eventTime;
                case 'conv_op_tilestart'
                    CONV_OP_TileStart{end+1}=eventTime;
                case 'conv_op_tiledone'
                    CONV_OP_TileDone{end+1}=eventTime;
                otherwise

                end
            end

            ConvLogCategory('conv_ip_tilestart')=CONV_IP_TileStart;
            ConvLogCategory('conv_ip_tiledone')=CONV_IP_TileDone;
            ConvLogCategory('conv_conv_start')=Conv_Conv_start;
            ConvLogCategory('conv_conv_done')=Conv_Conv_done;
            ConvLogCategory('conv_op_tilestart')=CONV_OP_TileStart;
            ConvLogCategory('conv_op_tiledone')=CONV_OP_TileDone;
            CNNLogCategory('conv')=ConvLogCategory;
        end

        function CNNLogCategory=getCNNLogCategoryVerbose_3(this,eventID,timestamp,cnnevents)


            CNNLogCategory=this.getCNNLogCategoryVerbose_1(eventID,timestamp,cnnevents);
            ConvLogCategory=CNNLogCategory('conv');
            Conv_IP_start={};
            Conv_IP_done={};
            Conv_Conv_start={};
            Conv_Conv_done={};
            Conv_OP_start={};
            Conv_OP_done={};

            for i=1:length(eventID)
                eventName=strcat(lower(cnnevents(eventID(i)).getName()));
                eventTime=timestamp(i);
                switch eventName
                case 'conv_ip_start'
                    Conv_IP_start{end+1}=eventTime;
                case 'conv_ip_done'
                    Conv_IP_done{end+1}=eventTime;
                case 'conv_conv_start'
                    Conv_Conv_start{end+1}=eventTime;
                case 'conv_conv_done'
                    Conv_Conv_done{end+1}=eventTime;
                case 'conv_op_start'
                    Conv_OP_start{end+1}=eventTime;
                case 'conv_op_done'
                    Conv_OP_done{end+1}=eventTime;
                otherwise

                end
            end
            ConvLogCategory('conv_ip_start')=Conv_IP_start;
            ConvLogCategory('conv_ip_done')=Conv_IP_done;
            ConvLogCategory('conv_conv_start')=Conv_Conv_start;
            ConvLogCategory('conv_conv_done')=Conv_Conv_done;
            ConvLogCategory('conv_op_start')=Conv_OP_start;
            ConvLogCategory('conv_op_done')=Conv_OP_done;
            CNNLogCategory('conv')=ConvLogCategory;
        end


        function[eventID,timestamp]=parse(this,RawLogs)
            row=[];
            col=[];
            val=[];
            for i=1:length(RawLogs)
                rlg=RawLogs(i).log;
                rts=RawLogs(i).timestamp;
                for seIdx=1:length(this.supportedEvents)
                    se=this.supportedEvents(seIdx);
                    if(se.isTriggered(rlg))

                        row(end+1)=se.getBitRange+1;
                        col(end+1)=rts+1;
                        val(end+1)=se.parse(rlg);

                    end
                end
            end









            eventID=row;
            timestamp=col;
        end

    end

end
