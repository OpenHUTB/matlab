classdef externalAudioPlugin<audioPlugin&audio.internal.loadableAudioPlugin













    properties(Hidden,SetAccess=private)
        Prepared=false
    end

    methods

        function plugin=externalAudioPlugin(pluginPath,pluginInstance)
            plugin=plugin@audio.internal.loadableAudioPlugin(pluginPath,pluginInstance);
        end

        function out=process(plugin,in)







            inst=plugin.PluginInstance;
            if~inst
                out=[];
                return
            end

            validateattributes(in,{'double'},{'real','2d'},'process','input');
            nin=hostmexif.getnuminputs(inst);
            nout=hostmexif.getnumoutputs(inst);
            nchans=max(nin,nout);
            nsamples=size(in,1);
            if size(in,2)~=nin
                error(message('audio:plugin:ProcessBadChannels',...
                size(in,2),nin));
            end
            if nsamples>getMaxSamplesPerFrame(plugin)
                plugName=inputname(1);
                if isempty(plugName)
                    plugName='plugin';
                end
                error(message('audio:plugin:MaxSamplesExceeded',...
                nsamples,getMaxSamplesPerFrame(plugin),plugName));
            end

            if~plugin.Prepared
                hostmexif.preparetoplay(inst,...
                getSampleRate(plugin),...
                int32(getMaxSamplesPerFrame(plugin)));
                plugin.Prepared=true;
            end

            doingDbl=hostmexif.isusingdouble(inst);
            if doingDbl
                processfcn='processdouble';
            else
                processfcn='processsingle';
                in=single(in);
            end
            if nin>nout
                in=hostmexif.(processfcn)(inst,in,int32(nchans),int32(nsamples));
                out=in(:,1:nout);
            else
                out=[in,zeros(nsamples,nout-nin)];
                out=hostmexif.(processfcn)(inst,out,int32(nchans),int32(nsamples));
            end
            out=double(out);
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
                details=sprintf('%d in, %d out\n',...
                double(hostmexif.getnuminputs(inst)),...
                double(hostmexif.getnumoutputs(inst)));
                dispKernel(plugin,details,inputname(1));
            else
                warning(message('audio:plugin:InstantiationFailed',plugin.PluginPath));
            end
        end

        function s=saveobj(obj)
            s=saveobj@audio.internal.loadableAudioPlugin(obj);
            s2=saveobj@audioPlugin(obj);

            cellfun(@(x)assignin('caller','s',setfield(evalin('caller','s'),x,s2.(x))),fieldnames(s2));


        end
        function obj=reload(obj,s)
            obj=reload@audio.internal.loadableAudioPlugin(obj,s);
            obj=reload@audioPlugin(obj,s);
        end
    end

    methods(Static)
        function obj=loadobj(s)
            if isstruct(s)
                try
                    obj=loadAudioPlugin(s.PluginPath);
                    obj=reload(obj,s);
                catch ex
                    obj=externalAudioPlugin(s.PluginPath,uint64(0));
                    warning(ex.identifier,"%s",ex.message);
                end
            end
        end
    end
end
