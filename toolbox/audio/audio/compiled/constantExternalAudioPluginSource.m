classdef constantExternalAudioPluginSource<audioPluginSource

%#codegen

    properties(Hidden)
        Prepared=false
PluginPath
PluginInstance
        MaxSamplesPerFrame=65536
    end


    methods
        function obj=constantExternalAudioPluginSource
            coder.allowpcode('plain');
        end


        function out=process(plugin)
            out=externalAudioPluginSimulink.processSource(plugin);
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
