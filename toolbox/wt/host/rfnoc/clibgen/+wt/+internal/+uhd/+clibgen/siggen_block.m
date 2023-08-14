classdef siggen_block<wt.internal.uhd.clibgen.block





    methods(Access=protected)
        function control=getCustomBlockController(obj)
            control=obj.graph.get_block_uhd__rfnoc__siggen_block_control_(getID(obj));
        end
    end

    methods
        function setWaveform(obj,waveform,channel)
            switch waveform
            case "sine_wave"
                waveform=clib.wt_uhd.uhd.rfnoc.siggen_waveform.SINE_WAVE;
            case "constant"
                waveform=clib.wt_uhd.uhd.rfnoc.siggen_waveform.CONSTANT;
            case "noise"
                waveform=clib.wt_uhd.uhd.rfnoc.siggen_waveform.NOISE;
            otherwise
                error(message("wt:rfnoc:driver:InvalidSiggenWaveform"));
            end
            obj.ctrl.set_waveform(waveform,uint64(channel));
        end

        function setAmplitude(obj,amplitude,channel)
            obj.ctrl.set_amplitude(amplitude,uint64(channel));
        end

        function setSineFrequency(obj,frequency,fs,channel)
            obj.ctrl.set_sine_frequency(frequency,fs,uint64(channel));
        end

        function setConstant(obj,constant,channel)
            obj.ctrl.set_constant(constant,uint64(channel));
        end

        function setEnable(obj,enable,channel)
            obj.ctrl.set_enable(enable,uint64(channel));
        end

        function setSamplesPerPacket(obj,nSamples,channel)
            obj.ctrl.set_samples_per_packet(uint64(nSamples),uint64(channel));
        end

        function issueStreamCommand(obj,stream_mode,~,channel,varargin)



            switch stream_mode
            case "continuous"
                obj.getControl.set_enable(true,uint64(channel));
            case "stop"
                obj.getControl.set_enable(false,uint64(channel));
            otherwise
                error(message("wt:rfnoc:driver:SiggenStreamModeNotAvailable"));
            end
        end
    end
end

