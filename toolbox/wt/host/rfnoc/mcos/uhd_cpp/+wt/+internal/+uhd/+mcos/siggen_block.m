



classdef siggen_block<wt.internal.uhd.mcos.block

    properties
    end

    methods
        function obj=siggen_block(radio,blockName,varargin)
            obj=obj@wt.internal.uhd.mcos.block(blockName,varargin);
            obj.ctrl=uhd.internal.siggen;
            makeBlock(obj,radio);
        end
    end

    methods(Hidden)
        function setWaveform(obj,waveform,port)
            obj.ctrl.setWaveform(lower(waveform),port);
        end

        function setAmplitude(obj,amplitude,channel)
            obj.ctrl.setAmplitude(amplitude,uint64(channel));
        end

        function setSineFrequency(obj,frequency,fs,channel)
            obj.ctrl.setSineFrequency(frequency,fs,uint64(channel));
        end





        function setEnable(obj,enable,channel)
            obj.ctrl.setEnable(enable,uint64(channel));
        end

        function setSamplesPerPacket(obj,nSamples,channel)
            obj.ctrl.setSamplesPerPacket(uint64(nSamples),uint64(channel));
        end

        function issueStreamCommand(obj,stream_mode,~,channel,varargin)



            switch stream_mode
            case "continuous"
                obj.ctrl.setEnable(true,uint64(channel));
            case "stop"
                obj.ctrl.setEnable(false,uint64(channel));
            otherwise
                error(message("wt:rfnoc:driver:SiggenStreamModeNotAvailable"));
            end
        end
    end

end
