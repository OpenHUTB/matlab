classdef pluginhostlibif<coder.ExternalDependency

%#codegen

    methods
        function obj=pluginhostlibif
            coder.allowpcode('plain');
        end
    end

    methods(Static,Hidden)
        function bName=getDescriptiveName(~)
            bName='Simulink Audio Plugin Host API';
        end
        function tf=isSupportedContext(ctx)
            if ctx.isMatlabHostTarget()
                tf=true;
            else
                coder.internal.error('audio:plugin:UnsupportedPlatformForAudioPluginHosting',computer('arch'));
            end
        end
        function updateBuildInfo(buildInfo,~)
            buildInfo.addIncludePaths('$(MATLAB_ROOT)/toolbox/audio/plugins');
            buildInfo.addIncludeFiles('jucehost.hpp');
            switch(computer("arch"))
            case "win64"
                buildInfo.addLinkObjects('jucehost.lib','$(MATLAB_ROOT)/lib/win64',100,true,true);
                buildInfo.addNonBuildFiles('jucehost.dll','$(MATLAB_ROOT)/bin/win64');
            case "maci64"
                buildInfo.addLinkFlags('-framework Accelerate -framework AudioToolbox -framework AudioUnit -framework Carbon -framework Cocoa -framework CoreAudio -framework CoreAudioKit -framework CoreMIDI -framework DiscRecording -framework IOKit -framework OpenGL -framework QTKit -framework QuartzCore -framework WebKit');
                buildInfo.addLinkObjects('libjucehost.dylib','$(MATLAB_ROOT)/bin/maci64',100,true,true);
            otherwise
                coder.internal.error('audio:plugin:UnsupportedPlatformForAudioPluginHosting',computer('arch'));
            end
        end


        function deleteplugininstance(eff)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            coder.ceval('deletePluginInstance',i1);
        end


        function deletepluginmanager(pm)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginManager*','NULL');
            i1=cast(pm,'like',i1);
            coder.ceval('deletePluginManager',i1);
        end


        function out=getnuminputs(eff)
            coder.cinclude('jucehost.hpp');
            out=coder.nullcopy(int32(0));
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            out=coder.ceval('getNumInputs',i1);
        end


        function out=getnumoutputs(eff)
            coder.cinclude('jucehost.hpp');
            out=coder.nullcopy(int32(0));
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            out=coder.ceval('getNumOutputs',i1);
        end


        function out=getnumparams(eff)
            coder.cinclude('jucehost.hpp');
            out=coder.nullcopy(int32(0));
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            out=coder.ceval('getNumParams',i1);
        end


        function out=getnumprograms(eff)
            coder.cinclude('jucehost.hpp');
            out=coder.nullcopy(int32(0));
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            out=coder.ceval('getNumPrograms',i1);
        end


        function paramDisplay=getparamdisplay(eff,paramIndex)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            o2=zeros(1,256,'uint32');
            coder.ceval('getParamDisplay',i1,paramIndex-1,coder.ref(o2));
            paramDisplay=o2(o2~=uint32(0));
        end


        function paramLabel=getparamlabel(eff,paramIndex)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            o2=zeros(1,256,'uint32');
            coder.ceval('getParamLabel',i1,paramIndex-1,coder.ref(o2));
            paramLabel=o2(o2~=uint32(0));
        end


        function paramName=getparamname(eff,paramIndex)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            o2=zeros(1,256,'uint32');
            coder.ceval('getParamName',i1,paramIndex-1,coder.ref(o2));
            paramName=o2(o2~=uint32(0));
        end


        function out=getparamvalue(eff,paramIndex)
            coder.cinclude('jucehost.hpp');
            out=coder.nullcopy(single(0));
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            out=coder.ceval('getParamValue',i1,paramIndex-1);
        end


        function formatName=getpluginformatname(eff)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            o2=zeros(1,256,'uint32');
            coder.ceval('getPluginFormatName',i1,coder.ref(o2));
            formatName=o2(o2~=uint32(0));
        end


        function effectName=getpluginname(eff)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            o2=zeros(1,256,'uint32');
            coder.ceval('getPluginName',i1,coder.ref(o2));
            effectName=o2(o2~=uint32(0));
        end


        function out=getuniqueid(eff)
            coder.cinclude('jucehost.hpp');
            out=coder.nullcopy(int32(0));
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            out=coder.ceval('getUniqueId',i1);
        end


        function vendorString=getvendorstring(eff)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            o2=zeros(1,256,'uint32');
            coder.ceval('getVendorString',i1,coder.ref(o2));
            vendorString=o2(o2~=uint32(0));
        end


        function vendorVersion=getvendorversion(eff)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            o2=zeros(1,256,'uint32');
            coder.ceval('getVendorVersion',i1,coder.ref(o2));
            vendorVersion=o2(o2~=uint32(0));
        end


        function out=isusingdouble(eff)
            coder.cinclude('jucehost.hpp');
            out=coder.nullcopy(false);
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            out=coder.ceval('isUsingDouble',i1);
        end


        function mexlock
            coder.cinclude('jucehost.hpp');
            coder.ceval('mexLock');
        end


        function mexunlock
            coder.cinclude('jucehost.hpp');
            coder.ceval('mexUnlock');
        end


        function out=newplugininstance(pm,filename)
            coder.cinclude('jucehost.hpp');
            o1=coder.opaque('PluginInstance*');
            i2=coder.opaque('PluginManager*','NULL');
            i2=cast(pm,'like',i2);
            o1=coder.ceval('newPluginInstance',i2,uint32([filename,uint32(0)]));
            out=coder.nullcopy(uint64(0));
            out=coder.ceval('ptr2uint64',o1);
        end


        function out=newpluginmanager
            coder.cinclude('jucehost.hpp');
            o1=coder.opaque('PluginManager*');
            o1=coder.ceval('newPluginManager');
            out=coder.nullcopy(uint64(0));
            out=coder.ceval('ptr2uint64',o1);
        end


        function preparetoplay(eff,sampleRate,frameSize)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            coder.ceval('prepareToPlay',i1,sampleRate,frameSize);
        end


        function buffer=processDouble(eff,buffer,nChannels,nSamples)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            coder.ceval('processDouble',i1,coder.ref(buffer),nChannels,nSamples);
        end


        function buffer=processSingle(eff,buffer,nChannels,nSamples)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            coder.ceval('processSingle',i1,coder.ref(buffer),nChannels,nSamples);
        end


        function releaseresources(eff)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            coder.ceval('releaseResources',i1);
        end


        function setparamvalue(eff,paramIndex,paramValue)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            coder.ceval('setParamValue',i1,paramIndex-1,paramValue);
        end


        function out=supportsdouble(eff)
            coder.cinclude('jucehost.hpp');
            out=coder.nullcopy(false);
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            out=coder.ceval('supportsDouble',i1);
        end


        function usedouble(eff,useDbl)
            coder.cinclude('jucehost.hpp');
            i1=coder.opaque('PluginInstance*','NULL');
            i1=cast(eff,'like',i1);
            coder.ceval('useDouble',i1,useDbl);
        end
    end
end


