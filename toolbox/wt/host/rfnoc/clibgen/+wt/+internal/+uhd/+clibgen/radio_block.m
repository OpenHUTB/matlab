classdef radio_block<wt.internal.uhd.clibgen.block


    methods(Access=protected)
        function control=getCustomBlockController(obj)
            control=obj.graph.get_block_uhd__rfnoc__radio_control_(getID(obj));
        end
        function stop(obj,channel)
            streamhelper=wt.internal.uhd.clibgen.stream("temp");
            tx_stream_cmd=streamhelper.configureStreamCommand("stop",0);
            obj.ctrl.issue_stream_cmd(tx_stream_cmd,channel);
        end
    end

    methods
        function val=getReceiveCenterFrequency(obj,channel)
            val=obj.ctrl.get_rx_frequency(channel);
        end

        function val=getReceiveGain(obj,channel,varargin)
            if nargin>2
                val=obj.ctrl.get_rx_gain(varargin{1},channel);
            else
                val=obj.ctrl.get_rx_gain(channel);
            end
        end

        function val=getTransmitGain(obj,channel,varargin)
            if nargin>2
                val=obj.ctrl.get_tx_gain(varargin{1},channel);
            else
                val=obj.ctrl.get_tx_gain(channel);
            end
        end

        function val=getTransmitCenterFrequency(obj,channel)
            val=obj.ctrl.get_tx_frequency(channel);
        end

        function val=setReceiveCenterFrequency(obj,freq,channel)
            val=obj.ctrl.set_rx_frequency(freq,channel);
        end

        function val=setReceiveGain(obj,gain,channel,varargin)
            if nargin>3
                val=obj.ctrl.set_rx_gain(gain,varargin{1},channel);
            else
                val=obj.ctrl.set_rx_gain(gain,channel);
            end
        end

        function val=setTransmitGain(obj,gain,channel,varargin)
            if nargin>3
                val=obj.ctrl.set_tx_gain(gain,varargin{1},channel);
            else
                val=obj.ctrl.set_tx_gain(gain,channel);
            end
        end

        function val=getReceiveAntennas(obj,chan)
            ants=obj.ctrl.get_rx_antennas(chan);
            val=ants.string;
        end

        function val=getTransmitAntennas(obj,chan)
            ants=obj.ctrl.get_tx_antennas(chan);
            val=ants.string;
        end

        function val=setTransmitCenterFrequency(obj,freq,channel)
            val=obj.ctrl.set_tx_frequency(freq,channel);
        end

        function setSamplesPerPacket(obj,spp,channel)
            obj.ctrl.set_properties(clib.wt_uhd.uhd.device_addr_t("spp="+num2str(spp)),channel);
        end
    end

    methods(Hidden)
        function val=setRate(obj,rate)
            val=obj.ctrl.set_rate(rate);
        end
    end
end
