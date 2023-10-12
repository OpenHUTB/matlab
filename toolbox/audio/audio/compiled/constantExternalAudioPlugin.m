classdef constantExternalAudioPlugin<audioPlugin


%#codegen

    properties(Hidden)
        Prepared=false
PluginPath
PluginInstance
        MaxSamplesPerFrame=65536
    end

    methods
        function obj=constantExternalAudioPlugin
            coder.allowpcode('plain');
        end

        function out=process(plugin,in)
            out=externalAudioPluginSimulink.process(plugin,in);
        end

        function setSampleRate(plugin,rate)
            setSampleRate@audioPlugin(plugin,rate);
            externalAudioPluginSimulink.setSampleRate(plugin);
        end

        function setMaxSamplesPerFrame(plugin,rate)
            plugin.MaxSamplesPerFrame=double(rate);
            externalAudioPluginSimulink.setMaxSamplesPerFrame(plugin);
        end

        function rate=getMaxSamplesPerFrame(plugin)
            rate=plugin.MaxSamplesPerFrame;
        end

        function s=info(plugin)
            s=externalAudioPluginSimulink.getInfo(plugin);
        end
    end
end
