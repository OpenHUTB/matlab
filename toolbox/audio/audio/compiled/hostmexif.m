



classdef hostmexif<coder.ExternalDependency %#codegen




    methods
        function obj=hostmexif
            coder.allowpcode('plain');
        end
    end

    methods(Static,Hidden)
        function bName=getDescriptiveName(~)
            bName='Audio Plugin Host API';
        end

        function tf=isSupportedContext(ctx)
            if ctx.isMatlabHostTarget()
                tf=true;
            else
                error('Audio Plugin Host MEX interface library not available for this target');
            end
        end

        function updateBuildInfo(buildInfo,~)
            if ismac
                buildInfo.addLinkFlags('-framework Accelerate -framework AudioToolbox -framework AudioUnit -framework Carbon -framework Cocoa -framework CoreAudio -framework CoreAudioKit -framework CoreMIDI -framework DiscRecording -framework IOKit -framework OpenGL -framework QTKit -framework QuartzCore -framework WebKit');
            end
        end


        function deleteplugininstance(eff)
            if coder.target('MATLAB')
                hostmexfcn('deleteplugininstance',eff);
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                coder.ceval('deletePluginInstance',i1);
            end
        end


        function deletepluginmanager(pm)
            if coder.target('MATLAB')
                hostmexfcn('deletepluginmanager',pm);
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginManager*','NULL');
                i1=cast(pm,'like',i1);
                coder.ceval('deletePluginManager',i1);
            end
        end


        function out=getnuminputs(eff)
            if coder.target('MATLAB')
                out=hostmexfcn('getnuminputs',eff);
            else
                coder.cinclude('jucehost.hpp');
                out=coder.nullcopy(int32(0));
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                out=coder.ceval('getNumInputs',i1);
            end
        end


        function out=getnumoutputs(eff)
            if coder.target('MATLAB')
                out=hostmexfcn('getnumoutputs',eff);
            else
                coder.cinclude('jucehost.hpp');
                out=coder.nullcopy(int32(0));
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                out=coder.ceval('getNumOutputs',i1);
            end
        end


        function out=getnumparams(eff)
            if coder.target('MATLAB')
                out=hostmexfcn('getnumparams',eff);
            else
                coder.cinclude('jucehost.hpp');
                out=coder.nullcopy(int32(0));
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                out=coder.ceval('getNumParams',i1);
            end
        end


        function out=getnumprograms(eff)
            if coder.target('MATLAB')
                out=hostmexfcn('getnumprograms',eff);
            else
                coder.cinclude('jucehost.hpp');
                out=coder.nullcopy(int32(0));
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                out=coder.ceval('getNumPrograms',i1);
            end
        end


        function paramDisplay=getparamdisplay(eff,paramIndex)
            if coder.target('MATLAB')
                paramDisplay=hostmexfcn('getparamdisplay',eff,paramIndex);
                if isempty(paramDisplay)
                    paramDisplay='';
                else
                    paramDisplay=char(paramDisplay);
                end
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                o2=zeros(1,256,'uint32');
                coder.ceval('getParamDisplay',i1,paramIndex-1,coder.ref(o2));
                paramDisplay=o2(o2~=uint32(0));
            end
        end


        function paramLabel=getparamlabel(eff,paramIndex)
            if coder.target('MATLAB')
                paramLabel=hostmexfcn('getparamlabel',eff,paramIndex);
                if isempty(paramLabel)
                    paramLabel='';
                else
                    paramLabel=char(paramLabel);
                end
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                o2=zeros(1,256,'uint32');
                coder.ceval('getParamLabel',i1,paramIndex-1,coder.ref(o2));
                paramLabel=o2(o2~=uint32(0));
            end
        end


        function paramName=getparamname(eff,paramIndex)
            if coder.target('MATLAB')
                paramName=hostmexfcn('getparamname',eff,paramIndex);
                if isempty(paramName)
                    paramName='';
                else
                    paramName=char(paramName);
                end
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                o2=zeros(1,256,'uint32');
                coder.ceval('getParamName',i1,paramIndex-1,coder.ref(o2));
                paramName=o2(o2~=uint32(0));
            end
        end


        function out=getparamvalue(eff,paramIndex)
            if coder.target('MATLAB')
                out=hostmexfcn('getparamvalue',eff,paramIndex);
            else
                coder.cinclude('jucehost.hpp');
                out=coder.nullcopy(single(0));
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                out=coder.ceval('getParamValue',i1,paramIndex-1);
            end
        end


        function formatName=getpluginformatname(eff)
            if coder.target('MATLAB')
                formatName=hostmexfcn('getpluginformatname',eff);
                if isempty(formatName)
                    formatName='';
                else
                    formatName=char(formatName);
                end
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                o2=zeros(1,256,'uint32');
                coder.ceval('getPluginFormatName',i1,coder.ref(o2));
                formatName=o2(o2~=uint32(0));
            end
        end


        function effectName=getpluginname(eff)
            if coder.target('MATLAB')
                effectName=hostmexfcn('getpluginname',eff);
                if isempty(effectName)
                    effectName='';
                else
                    effectName=char(effectName);
                end
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                o2=zeros(1,256,'uint32');
                coder.ceval('getPluginName',i1,coder.ref(o2));
                effectName=o2(o2~=uint32(0));
            end
        end


        function out=getuniqueid(eff)
            if coder.target('MATLAB')
                out=hostmexfcn('getuniqueid',eff);
            else
                coder.cinclude('jucehost.hpp');
                out=coder.nullcopy(int32(0));
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                out=coder.ceval('getUniqueId',i1);
            end
        end


        function vendorString=getvendorstring(eff)
            if coder.target('MATLAB')
                vendorString=hostmexfcn('getvendorstring',eff);
                if isempty(vendorString)
                    vendorString='';
                else
                    vendorString=char(vendorString);
                end
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                o2=zeros(1,256,'uint32');
                coder.ceval('getVendorString',i1,coder.ref(o2));
                vendorString=o2(o2~=uint32(0));
            end
        end


        function vendorVersion=getvendorversion(eff)
            if coder.target('MATLAB')
                vendorVersion=hostmexfcn('getvendorversion',eff);
                if isempty(vendorVersion)
                    vendorVersion='';
                else
                    vendorVersion=char(vendorVersion);
                end
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                o2=zeros(1,256,'uint32');
                coder.ceval('getVendorVersion',i1,coder.ref(o2));
                vendorVersion=o2(o2~=uint32(0));
            end
        end


        function out=isusingdouble(eff)
            if coder.target('MATLAB')
                out=hostmexfcn('isusingdouble',eff);
            else
                coder.cinclude('jucehost.hpp');
                out=coder.nullcopy(false);
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                out=coder.ceval('isUsingDouble',i1);
            end
        end


        function mexlock
            if coder.target('MATLAB')
                hostmexfcn('mexlock');
            else
                coder.cinclude('jucehost.hpp');
                coder.ceval('mexLock');
            end
        end


        function mexunlock
            if coder.target('MATLAB')
                hostmexfcn('mexunlock');
            else
                coder.cinclude('jucehost.hpp');
                coder.ceval('mexUnlock');
            end
        end


        function out=newplugininstance(pm,filename)
            if coder.target('MATLAB')
                out=hostmexfcn('newplugininstance',pm,uint32(filename));
            else
                coder.cinclude('jucehost.hpp');
                o1=coder.opaque('PluginInstance*');
                i2=coder.opaque('PluginManager*','NULL');
                i2=cast(pm,'like',i2);
                o1=coder.ceval('newPluginInstance',i2,[filename,uint32(0)]);
                out=coder.nullcopy(uint64(0));
                out=coder.ceval('ptr2uint64',o1);
            end
        end


        function out=newpluginmanager
            if coder.target('MATLAB')
                out=hostmexfcn('newpluginmanager');
            else
                coder.cinclude('jucehost.hpp');
                o1=coder.opaque('PluginManager*');
                o1=coder.ceval('newPluginManager');
                out=coder.nullcopy(uint64(0));
                out=coder.ceval('ptr2uint64',o1);
            end
        end


        function preparetoplay(eff,sampleRate,frameSize)
            if coder.target('MATLAB')
                hostmexfcn('preparetoplay',eff,sampleRate,frameSize);
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                coder.ceval('prepareToPlay',i1,sampleRate,frameSize);
            end
        end


        function buffer=processdouble(eff,buffer,nChannels,nSamples)
            if coder.target('MATLAB')
                buffer=hostmexfcn('processdouble',eff,buffer,nChannels,nSamples);
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                coder.ceval('processDouble',i1,coder.ref(buffer),nChannels,nSamples);
            end
        end


        function buffer=processsingle(eff,buffer,nChannels,nSamples)
            if coder.target('MATLAB')
                buffer=hostmexfcn('processsingle',eff,buffer,nChannels,nSamples);
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                coder.ceval('processSingle',i1,coder.ref(buffer),nChannels,nSamples);
            end
        end


        function releaseresources(eff)
            if coder.target('MATLAB')
                hostmexfcn('releaseresources',eff);
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                coder.ceval('releaseResources',i1);
            end
        end


        function setparamvalue(eff,paramIndex,paramValue)
            if coder.target('MATLAB')
                hostmexfcn('setparamvalue',eff,paramIndex,paramValue);
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                coder.ceval('setParamValue',i1,paramIndex-1,paramValue);
            end
        end


        function out=supportsdouble(eff)
            if coder.target('MATLAB')
                out=hostmexfcn('supportsdouble',eff);
            else
                coder.cinclude('jucehost.hpp');
                out=coder.nullcopy(false);
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                out=coder.ceval('supportsDouble',i1);
            end
        end


        function usedouble(eff,useDbl)
            if coder.target('MATLAB')
                hostmexfcn('usedouble',eff,useDbl);
            else
                coder.cinclude('jucehost.hpp');
                i1=coder.opaque('PluginInstance*','NULL');
                i1=cast(eff,'like',i1);
                coder.ceval('useDouble',i1,useDbl);
            end
        end

    end
end
