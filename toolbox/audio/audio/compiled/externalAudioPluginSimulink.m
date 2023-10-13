classdef externalAudioPluginSimulink<handle

%#codegen

    methods
        function obj=externalAudioPluginSimulink
            coder.allowpcode('plain');
        end
    end

    methods(Static)

        function setSimulinkAudioPlugin(pluginPath,pluginInstance,plugin)
            plugin.PluginPath=pluginPath;
            plugin.PluginInstance=pluginInstance;
            doesDbl=pluginhostlibif.supportsdouble(pluginInstance);
            pluginhostlibif.usedouble(pluginInstance,doesDbl);
        end

        function y=process(plugin,in)
            coder.varsize("out")
            inst=plugin.PluginInstance;

            nin=pluginhostlibif.getnuminputs(inst);
            nout=pluginhostlibif.getnumoutputs(inst);
            nsamples=size(in,1);
            nChans=max(nin,nout);

            if~plugin.Prepared
                pluginhostlibif.preparetoplay(inst,...
                getSampleRate(plugin),...
                int32(getMaxSamplesPerFrame(plugin)));
                plugin.Prepared=true;
            end

            doingDbl=pluginhostlibif.isusingdouble(inst);

            if nin>nout
                if doingDbl
                    in=pluginhostlibif.processDouble(inst,in,int32(nChans),int32(nsamples));
                    out=in(:,1:nout);
                else
                    in=pluginhostlibif.processSingle(inst,single(in),int32(nChans),int32(nsamples));
                    out=double(in(:,1:nout));
                end
            else
                out=[in,zeros(nsamples,nout-nin)];
                if doingDbl
                    out=double(pluginhostlibif.processDouble(inst,out,int32(nChans),int32(nsamples)));
                else
                    out=double(pluginhostlibif.processSingle(inst,single(out),int32(nChans),int32(nsamples)));
                end
            end
            y=out;
        end

        function setMaxSamplesPerFrame(plugin)
            inst=plugin.PluginInstance;
            if inst&&plugin.Prepared
                pluginhostlibif.releaseresources(inst);
                plugin.Prepared=false;
            end
        end

        function setSampleRate(plugin)
            inst=plugin.PluginInstance;
            if inst&&plugin.Prepared
                pluginhostlibif.releaseresources(inst);
                plugin.Prepared=false;
            end
        end

        function setParameter(plugin,param,value)
            inst=plugin.PluginInstance;
            if inst==0
                return
            end

            param=checkParamArg(plugin,param,'setParameter');

            validateattributes(value,{'numeric'},...
            {'scalar','real','finite',...
            '>=',0,'<=',1},'setParameter','value');

            pluginhostlibif.setparamvalue(inst,int32(param),single(value));
        end

        function setProperty(plugin,pa,pnum,val)
            if pa.IsNumeric
                setNumericProperty(pa,val,plugin,pnum);
            else
                setNonNumericProperty(pa,val,plugin,pnum);
            end
        end

        function propDispVal=getPropertyDisplayValue(pluginInstance,pnum)
            coder.varsize('paramValue',[1,256]);
            propDispVal=pluginhostlibif.getparamdisplay(pluginInstance,int32(pnum));
        end
        function pluginInstance=loadPluginBinary(pluginPath)

            pluginManager=getPluginManager;
            coder.internal.errorIf(pluginManager==0,'audio:plugin:PluginManagerFailed');


            pluginInstance=pluginhostlibif.newplugininstance(pluginManager,pluginPath);
            coder.internal.errorIf(pluginInstance==0,'audio:plugin:InstantiationFailed');
        end
        function out=processSource(plugin)
            inst=plugin.PluginInstance;
            if~inst
                out=[];
                return
            end

            if~plugin.Prepared
                pluginhostlibif.preparetoplay(inst,...
                getSampleRate(plugin),...
                int32(getMaxSamplesPerFrame(plugin)));
                plugin.Prepared=true;
            end

            nout=pluginhostlibif.getnumoutputs(inst);
            nsamples=getSamplesPerFrame(plugin);

            doingDbl=pluginhostlibif.isusingdouble(inst);
            if doingDbl
                out=zeros(nsamples,nout);
                out=pluginhostlibif.processDouble(inst,out,int32(nout),int32(nsamples));
            else
                sout=zeros(nsamples,nout,'single');
                sout=pluginhostlibif.processSingle(inst,sout,int32(nout),int32(nsamples));
                out=double(sout);
            end
        end
    end
end

function paramStr=checkParamStringArg(plugin,paramStr,fcn)%#ok<INUSL>
    if isstring(paramStr)
        validateattributes(paramStr,{'string'},{'scalar'},...
        fcn,'param');
        paramStr=char(paramStr);
    elseif ischar(paramStr)
        validateattributes(paramStr,{'char'},{'row'},...
        fcn,'param');
    end
end

function paramIdx=checkParamArg(plugin,param,fcn)
    inst=plugin.PluginInstance;
    numParams=pluginhostlibif.getnumparams(inst);
    coder.internal.errorIf(numParams==0,'audio:plugin:ParamIdxNoParams');
    param=checkParamStringArg(plugin,param,fcn);

    if ischar(param)
        paramIdx=paramIdxFromDisplayName(plugin,param);
        coder.internal.errorIf(isempty(paramIdx),'audio:plugin:ParamIdxNoSuch',param);
        coder.internal.errorIf(numel(paramIdx)>1,'audio:plugin:ParamIdxNotUnique',param,sprintf(' %d',paramIdx));
    else
        validateattributes(param,{'numeric'},...
        {'scalar','real','finite','integer'...
        ,'>=',1,'<=',numParams},fcn,'param');
        paramIdx=param;
    end
end

function setNumericProperty(pa,val,plugin,pnum)
    from=pa.Numbers;
    to=pa.NormalizedValues;

    coder.internal.errorIf(pa.Monotonicity==0,'audio:plugin:ParameterPropertyNotMonotonic',pa.PropertyName,pnum);
    if pa.Monotonicity<0

        from=flipud(from);
        to=flipud(to);
    end
    if~isempty(from)
        if isinf(from(1))
            from(1)=-realmax;
        end
        if isinf(from(end))
            from(end)=realmax;
        end
        if numel(pa.Numbers)==1
            normValue=x;
        else
            normValue=pchip(from,to,val);
        end

        externalAudioPluginSimulink.setParameter(plugin,pnum,normValue(1));
    end
end

function setNonNumericProperty(pa,val,plugin,pnum)
    from=pa.ValueStrings;
    to=pa.NormalizedValues;
    isVal=strcmp(from,val);
    valIdx=find(isVal==1);
    normalizedValue=to(valIdx(1));
    externalAudioPluginSimulink.setParameter(plugin,pnum,normalizedValue);
end


function pm=getPluginManager()
    pluginManager=pluginhostlibif.newpluginmanager;
    pm=pluginManager;
    if isempty(pluginManager)
        pluginhostlibif.mexlock;
        if coder.target('MATLAB')
            oc=onCleanup(@cleanupPluginManager);
        else
            coder.internal.atexit(@cleanupPluginManager);
        end
    end
end

function cleanupPluginManager
    pm=getPluginManager;
    pluginhostlibif.deletepluginmanager(pm);
end


