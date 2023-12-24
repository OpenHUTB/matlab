classdef Driver<wt.internal.rfnoc.Driver

    methods
        function obj=Driver(radioObj,appObj)
            obj=obj@wt.internal.rfnoc.Driver(radioObj,appObj);
        end

        function[data,numSamps,overflow]=receive(obj,receiveLength,timeout)
            customStreamCommand=obj.getCustomStreamCommandSetSPP(receiveLength);
            [data,numSamps,overflow]=burstReceiveFromStream(obj,receiveLength,timeout,"0/RX_STREAM#0",customStreamCommand);
        end

        function[data,numSamps,overflow]=receiveViaOnboardMemory(obj,receiveLength,~)
            customStreamCommand=obj.getCustomStreamCommandSetSPP(receiveLength);
            data=receiveBurstFromStreamViaReplayBlockWM(obj,receiveLength,"0/RX_STREAM#0",receiveLength/obj.App.SampleRate+1,customStreamCommand);
            numSamps=length(data);
            overflow=false;
        end


        function transmitViaOnboardMemory(obj,waveform,mode)
            switch mode
            case wt.internal.TransmitModes.continuous
                transmitRepeatToStreamViaReplayBlock(obj,waveform,"0/TX_STREAM#0")
            case wt.internal.TransmitModes.once
                transmitBurstToStreamViaReplayBlock(obj,waveform,"0/TX_STREAM#0")
            end
        end


        function stopTransmitViaOnboardMemory(obj)
            obj.stopTransmitRepeatViaReplayBlock("0/TX_STREAM#0");
        end


        function disconnect(obj)
            disconnect@wt.internal.rfnoc.Driver(obj);
        end
    end


    methods(Access=private)
        function[graph,rx_stream_list,tx_stream_list]=getGraphReceiver(obj,uhd_datatype_host_rx,uhd_datatype_host_tx,otw_datatype)
            graph={};
            for antIdx=1:length(obj.App.ReceiveAntennas)
                [RadioBlock,RadioChannel]=getAntennaInfo(obj.Radio,obj.App.ReceiveAntennas(antIdx));
                charRadioBlock=char(RadioBlock);
                farrowBlock=obj.getFarrowBlockName(obj.App.ReceiveAntennas(antIdx));
                ddcBlock=['0/DDC#',charRadioBlock(end)];
                ddcChannel=RadioChannel;
                graph=[graph(:)',{RadioBlock},{RadioChannel},{farrowBlock},{0}];
                graph=[graph(:)',{farrowBlock},{0},{ddcBlock},{ddcChannel}];

                if obj.App.UseOnboardMemory

                    graph=[graph(:)',{ddcBlock},{ddcChannel},{"0/Replay#0"},{antIdx-1}];

                    graph=[graph(:)',{"0/Replay#0"},{antIdx-1},{"0/RX_STREAM#0"},{antIdx-1}];
                else

                    graph=[graph(:)',{ddcBlock},{ddcChannel},{"0/RX_STREAM#0"},{antIdx-1}];
                end
            end
            rx_stream_list=["0/RX_STREAM#0",uhd_datatype_host_rx,otw_datatype];
            tx_stream_list=[];
        end
        function[graph,rx_stream_list,tx_stream_list]=getGraphTransmitter(obj,uhd_datatype_host_rx,uhd_datatype_host_tx,otw_datatype)
            graph={};
            for antIdx=1:length(obj.App.TransmitAntennas)
                [RadioBlock,RadioChannel]=getAntennaInfo(obj.Radio,obj.App.TransmitAntennas(antIdx));
                charRadioBlock=char(RadioBlock);
                ducBlock=['0/DUC#',charRadioBlock(end)];
                ducChannel=RadioChannel;
                graph=[graph(:)',{ducBlock},{ducChannel},{RadioBlock},{RadioChannel}];

                graph=[graph(:)',{"0/Replay#0"},{antIdx-1},{ducBlock},{ducChannel}];

                graph=[graph(:)',{"0/TX_STREAM#0"},{antIdx-1},{"0/Replay#0"},{(antIdx-1)}];
            end
            rx_stream_list=[];
            tx_stream_list=["0/TX_STREAM#0",uhd_datatype_host_tx,otw_datatype];
        end

        function[graph,rx_stream_list,tx_stream_list]=getGraphTransceiver(obj,uhd_datatype_host_rx,uhd_datatype_host_tx,otw_datatype)
            graph={};
            for antIdx=1:length(obj.App.ReceiveAntennas)
                [RadioBlock,RadioChannel]=getAntennaInfo(obj.Radio,obj.App.ReceiveAntennas(antIdx));
                charRadioBlock=char(RadioBlock);
                farrowBlock=obj.getFarrowBlockName(obj.App.ReceiveAntennas(antIdx));
                ddcBlock=['0/DDC#',charRadioBlock(end)];
                ddcChannel=RadioChannel;
                graph=[graph(:)',{RadioBlock},{RadioChannel},{farrowBlock},{0}];
                graph=[graph(:)',{farrowBlock},{0},{ddcBlock},{ddcChannel}];

                graph=[graph(:)',{ddcBlock},{ddcChannel},{"0/Replay#0"},{antIdx-1}];

                graph=[graph(:)',{"0/Replay#0"},{antIdx-1},{"0/RX_STREAM#0"},{antIdx-1}];
            end
            for antIdx=1:length(obj.App.TransmitAntennas)
                [RadioBlock,RadioChannel]=getAntennaInfo(obj.Radio,obj.App.TransmitAntennas(antIdx));
                charRadioBlock=char(RadioBlock);
                ducBlock=['0/DUC#',charRadioBlock(end)];
                ducChannel=RadioChannel;
                graph=[graph(:)',{ducBlock},{ducChannel},{RadioBlock},{RadioChannel}];

                addEdge(obj.driverImpl,{"0/Replay#0",(antIdx-1+length(obj.App.ReceiveAntennas)),ducBlock,ducChannel},false);

                graph=[graph(:)',{"0/TX_STREAM#0"},{antIdx-1},{"0/Replay#0"},{(antIdx-1+length(obj.App.ReceiveAntennas))}];
            end
            rx_stream_list=["0/RX_STREAM#0",uhd_datatype_host_rx,otw_datatype];
            tx_stream_list=["0/TX_STREAM#0",uhd_datatype_host_tx,otw_datatype];
        end
    end


    methods(Access=protected)
        function[graph,rx_stream_list,tx_stream_list]=getGraph(obj)
            dataTypeMap=containers.Map(...
            ["int16","double","single"],...
            ["sc16","fc64","fc32"]);

            uhd_datatype_host_rx=dataTypeMap(string(obj.App.CaptureDataType));
            uhd_datatype_host_tx=dataTypeMap(string(obj.App.TransmitDataType));
            otw_datatype="sc16";
            if~isstring(obj.App.TransmitAntennas)

                [graph,rx_stream_list,tx_stream_list]=getGraphReceiver(obj,uhd_datatype_host_rx,uhd_datatype_host_tx,otw_datatype);
                return
            end
            if~isstring(obj.App.ReceiveAntennas)

                [graph,rx_stream_list,tx_stream_list]=getGraphTransmitter(obj,uhd_datatype_host_rx,uhd_datatype_host_tx,otw_datatype);
                return
            end

            [graph,rx_stream_list,tx_stream_list]=getGraphTransceiver(obj,uhd_datatype_host_rx,uhd_datatype_host_tx,otw_datatype);
        end
    end
end
