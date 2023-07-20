



classdef radio_block<wt.internal.uhd.mcos.block

    properties
    end

    methods
        function obj=radio_block(radio,blockName,varargin)
            obj=obj@wt.internal.uhd.mcos.block(blockName,varargin);
            obj.ctrl=uhd.internal.radio;
            makeBlock(obj,radio);
        end

        function val=getRate(obj)
            val=obj.ctrl.getRate();
        end

        function val=getReceiveCenterFrequency(obj,chan,varargin)
            val=obj.ctrl.getReceiveCenterFrequency(chan);
        end

        function val=getReceiveGain(obj,chan)
            val=obj.ctrl.getReceiveGain(chan);
        end

        function val=getTransmitGain(obj,chan)
            val=obj.ctrl.getTransmitGain(chan);
        end

        function val=getTransmitCenterFrequency(obj,chan)
            val=obj.ctrl.getTransmitCenterFrequency(chan);
        end

        function val=setReceiveCenterFrequency(obj,freq,chan)
            val=obj.ctrl.setReceiveCenterFrequency(freq,chan);
        end


        function val=setReceiveGain(obj,gain,chan)
            val=obj.ctrl.setReceiveGain(gain,chan);
        end

        function val=setTransmitGain(obj,gain,chan)
            val=obj.ctrl.setTransmitGain(gain,chan);
        end

        function val=getReceiveAntennas(obj,chan)
            val=obj.ctrl.getReceiveAntennas(chan);
        end

        function val=getTransmitAntennas(obj,chan)
            val=obj.ctrl.getTransmitAntennas(chan);
        end

        function val=setTransmitCenterFrequency(obj,freq,chan)
            val=obj.ctrl.setTransmitCenterFrequency(freq,chan);
        end

        function setSamplesPerPacket(obj,spp,channel)
            obj.ctrl.setProperties("spp="+num2str(spp),channel);
        end
    end

    methods(Hidden)
        function sampleRate=setRate(obj,val)
            sampleRate=obj.ctrl.setSampleRate(val);
        end
    end
end
