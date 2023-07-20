classdef externalAudioPluginSource<audioPluginSource&audio.internal.loadableAudioPlugin













    properties(Hidden,SetAccess=private)
        Prepared=false
    end

    methods

        function plugin=externalAudioPluginSource(pluginPath,pluginInstance)
            plugin=plugin@audio.internal.loadableAudioPlugin(pluginPath,pluginInstance);
        end

        function out=process(plugin)










            inst=plugin.PluginInstance;
            if~inst
                out=[];
                return
            end

            if~plugin.Prepared
                hostmexif.preparetoplay(inst,...
                getSampleRate(plugin),...
                int32(getMaxSamplesPerFrame(plugin)));
                plugin.Prepared=true;
            end

            nout=hostmexif.getnumoutputs(inst);
            nsamples=getSamplesPerFrame(plugin);
            if nsamples>getMaxSamplesPerFrame(plugin)
                plugName=inputname(1);
                if isempty(plugName)
                    plugName='plugin';
                end
                error(message('audio:plugin:MaxSamplesExceeded',...
                nsamples,getMaxSamplesPerFrame(plugin),plugName));
            end
            doingDbl=hostmexif.isusingdouble(inst);
            if doingDbl
                out=zeros(nsamples,nout);
                out=hostmexif.processdouble(inst,out,int32(nout),int32(nsamples));
            else
                sout=zeros(nsamples,nout,'single');
                sout=hostmexif.processsingle(inst,sout,int32(nout),int32(nsamples));
                out=double(sout);
            end
        end

        function setSampleRate(plugin,rate)





            setSampleRate@audioPlugin(plugin,rate);

            inst=plugin.PluginInstance;
            if inst&&plugin.Prepared
                hostmexif.releaseresources(inst);
                plugin.Prepared=false;
            end
        end

        function setMaxSamplesPerFrame(plugin,rate)





            setMaxSamplesPerFrame@audio.internal.loadableAudioPlugin(plugin,rate);

            inst=plugin.PluginInstance;
            if inst&&plugin.Prepared
                hostmexif.releaseresources(inst);
                plugin.Prepared=false;
            end
        end

        function s=info(plugin)































            s=getInfo(plugin);
        end

        function disp(plugin)
            inst=plugin.PluginInstance;
            if inst
                details=sprintf('source, %d out, %d samples\n',...
                double(hostmexif.getnumoutputs(inst)),...
                getSamplesPerFrame(plugin));
                dispKernel(plugin,details,inputname(1));
            else
                warning(message('audio:plugin:InstantiationFailed',plugin.PluginPath));
            end
        end

        function s=saveobj(obj)
            s=saveobj@audio.internal.loadableAudioPlugin(obj);
            s2=saveobj@audioPluginSource(obj);

            cellfun(@(x)assignin('caller','s',setfield(evalin('caller','s'),x,s2.(x))),fieldnames(s2));


        end
        function obj=reload(obj,s)
            obj=reload@audio.internal.loadableAudioPlugin(obj,s);
            obj=reload@audioPluginSource(obj,s);
        end
    end

    methods(Static)
        function obj=loadobj(s)
            if isstruct(s)
                try
                    obj=loadAudioPlugin(s.PluginPath);
                    obj=reload(obj,s);
                catch ex
                    obj=externalAudioPluginSource(s.PluginPath,uint64(0));
                    warning(ex.identifier,"%s",ex.message);
                end
            end
        end
    end
end
