


classdef(Abstract)ChannelAXI4StreamBase<hdlturnkey.data.Channel


    properties(Access=public,Hidden=true)





        ChannelPortLabel='';


        ChannelIdx=0;


        ExtTopInportSignals={};
        ExtTopOutportSignals={};




        NeedAutoReadyWiring=false;
        AutoReadyConnectionID='auto_ready';



        AutoReadyDutEnbConnectionID='auto_ready_dut_enb';


        RDOverrideDataBitwidth=0;
    end

    properties(Access=public,Hidden=true)


        ExtInportNames={};
        ExtOutportNames={};
        ExtInportWidths={};
        ExtOutportWidths={};
        ExtInportDimensions={};
        ExtOutportDimensions={};
        ExtInportWidthsFlattened={};
        ExtOutportWidthsFlattened={};
        ExtInportTotalWidth={};
        ExtOutportTotalWidth={};
        ExtInportDimensionsFlattened={};
        ExtOutportDimensionsFlattened={};


        ExtInportList={};
        ExtOutportList={};
        PackingMode='';
        SamplePackingDimension='';


        UserInportNames={};
        UserOutportNames={};
        UserInportWidths={};
        UserOutportWidths={};
        UserInportDimensions={};
        UserOutportDimensions={};


        UserInportList={};
        UserOutportList={};

        UserAssignedInportPorts={};
        UserAssignedOutportPorts={};

        UserTopInportSignals={};
        UserTopOutportSignals={};


        AutoInportNames={};
        AutoOutportNames={};
        AutoInportWidths={};
        AutoOutportWidths={};
        AutoInportDimensions={};
        AutoOutportDimensions={};
        AutoTopInportSignals={};
        AutoTopOutportSignals={};

    end

    properties(Access=protected)


        hDataPort=[];
        hReadyPort=[];

    end

    methods(Access=public)

        function obj=ChannelAXI4StreamBase(channelID,channelIdx,channelPortLabel)

            obj=obj@hdlturnkey.data.Channel(channelID);

            obj.ChannelPortLabel=channelPortLabel;
            obj.ChannelIdx=channelIdx;

            obj.hDataPort=[];
            obj.hReadyPort=[];

        end

        function hPort=getDataPort(obj)
            hPort=obj.hDataPort;
        end
        function hPort=getReadyPort(obj)
            hPort=obj.hReadyPort;
        end

        function isa=isDataPort(obj,hPort)
            isa=obj.hDataPort==hPort;
        end
        function isa=isReadyPort(obj,hPort)
            isa=obj.hReadyPort==hPort;
        end

        function isa=isReadyPortAssigned(obj)
            hPort=obj.getReadyPort;
            if isempty(hPort)
                isa=false;
            else
                isa=hPort.isAssigned;
            end
        end
        function isa=isFrameToSample(~,~)

            isa=false;
        end


        function validateExistingSubPortAssignment(obj,portName)

            [isAnySubPortAssigned,hSubPort]=obj.isAnySubPortAssigned;
            if isAnySubPortAssigned
                assignedPortName=hSubPort.getAssignedPortName;
                error(message('hdlcommon:interface:SubPortVectorPortOnly',...
                obj.ChannelID,portName,obj.ChannelID,...
                assignedPortName));
            end
        end

        function[portWidth,portDimension,totalDataWidth,isComplex]=getDataPortWidth(obj,hSubPort,PackingMode)
















            [portWidth,portDimension,isComplex]=hSubPort.getAssignedPortWidth;
            if obj.RDOverrideDataBitwidth>0
                totalDataWidth=obj.RDOverrideDataBitwidth;
                return;
            end




            if(strcmp(obj.SamplePackingDimension,'None'))
                isFrameMode=true;
            else
                isFrameMode=false;
            end

            [totalDataWidth,~]=hdlshared.internal.VectorStreamUtils.getPackedDataWidth(portWidth,portDimension,isComplex,PackingMode,isFrameMode);
        end



        function FlattenExtportsWidthsandDimensions(obj)
            obj.ExtInportWidthsFlattened={};
            obj.ExtOutportWidthsFlattened={};
            obj.ExtInportDimensionsFlattened={};
            obj.ExtOutportDimensionsFlattened={};


            numBusInports=numel(obj.ExtInportNames);
            obj.ExtInportWidthsFlattened=cell(1,numBusInports);
            obj.ExtInportDimensionsFlattened=cell(1,numBusInports);

            for ii=1:numBusInports

                if(obj.ExtInportDimensions{ii}>1)
                    obj.ExtInportWidthsFlattened{ii}=obj.ExtInportTotalWidth{ii};
                    obj.ExtInportDimensionsFlattened{ii}=1;
                else
                    obj.ExtInportWidthsFlattened{ii}=obj.ExtInportTotalWidth{ii};
                    obj.ExtInportDimensionsFlattened{ii}=obj.ExtInportDimensions{ii};
                end
            end

            numBusOutports=numel(obj.ExtOutportNames);
            for ii=1:numBusOutports

                if(obj.ExtOutportDimensions{ii}>1)
                    obj.ExtOutportWidthsFlattened{ii}=obj.ExtOutportTotalWidth{ii};
                    obj.ExtOutportDimensionsFlattened{ii}=1;
                else
                    obj.ExtOutportWidthsFlattened{ii}=obj.ExtOutportTotalWidth{ii};
                    obj.ExtOutportDimensionsFlattened{ii}=obj.ExtOutportDimensions{ii};
                end
            end
        end


        function demuxOutSignals=leftextend(~,ResidualWidth,hN,zeroSigPrefix,demuxOutSignals)
            constMaxBitWidth=128;
            ceilDim=ceil(ResidualWidth/constMaxBitWidth);
            for jj=1:ceilDim
                zeroSigName=sprintf('%s_%d',zeroSigPrefix,jj);


                if ResidualWidth==0
                    demuxOutSignals=demuxOutSignals;
                elseif ResidualWidth<constMaxBitWidth&&ResidualWidth~=0
                    demuxOutSignals(end+1)=hN.addSignal(pir_ufixpt_t(ResidualWidth,0),zeroSigName);
                else
                    demuxOutSignals(end+1)=hN.addSignal(pir_ufixpt_t(constMaxBitWidth,0),zeroSigName);
                    ResidualWidth=ResidualWidth-constMaxBitWidth;
                end
            end
        end
    end
end



