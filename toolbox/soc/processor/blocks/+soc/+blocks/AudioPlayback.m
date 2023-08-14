classdef AudioPlayback<matlab.System&coder.ExternalDependency




%#codegen

    properties(Nontunable)
        NumberOfChannels=2;
        BlockID='';
    end

    properties(Access=private)
        AudioPlaybackParams;
        AudioPlaybackHandle;
        DataTypeInBytes;
        DataTypeID;
    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=1;
        end

        function num=getNumOutputsImpl(~)
            num=0;
        end

        function flag=allowModelReferenceDiscreteSampleTimeInheritanceImpl(~)
            flag=true;
        end
    end

    methods
        function obj=AudioPlayback(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)
        function validateInputsImpl(obj,in)
            switch class(in)
            case 'int8'
                obj.DataTypeInBytes=1;
                obj.DataTypeID=0;
            case 'int16'
                obj.DataTypeInBytes=2;
                obj.DataTypeID=1;
            case 'int32'
                obj.DataTypeInBytes=4;
                obj.DataTypeID=2;
            end
        end

        function h=getNumSamples(obj)

            thisSize=propagatedInputSize(obj,1);
            h=thisSize(1)*thisSize(2);
        end

        function setupImpl(obj)
            coder.extrinsic('codertarget.peripherals.utils.getPeripheralDataStructType');
            if coder.target('rtw')
                coder.cinclude('mw_soc_audioplayback.h');
                str=coder.const(...
                codertarget.peripherals.utils.getPeripheralDataStructType('AudioPlayback'));
                coder.ceval("extern "+str+" "+obj.BlockID+";//");
                str=coder.const(obj.BlockID);
                blockCustParams=coder.opaque('MW_Void_Ptr_T',...
                coder.const("(MW_Void_Ptr_T)"+"&"+str),...
                'HeaderFile','mw_soc_drv_generic.h');
                blockParamsLoc=struct;
                coder.cstructname(blockParamsLoc,...
                'MW_AudioPlayback_Params_T','extern',...
                'HeaderFile','mw_soc_audioplayback.h');
                blockParamsLoc.numChannels=obj.NumberOfChannels;
                obj.AudioPlaybackParams=blockParamsLoc;
                obj.AudioPlaybackHandle=coder.opaque(...
                'MW_Void_Ptr_T',...
                'HeaderFile',...
                'mw_soc_audioplayback.h');
                obj.AudioPlaybackHandle=coder.ceval(...
                'MW_AudioPlayback_Init',...
                coder.ref(obj.AudioPlaybackParams),...
                obj.DataTypeID,...
                obj.getNumSamples/obj.NumberOfChannels,...
                blockCustParams);
            end
        end

        function stepImpl(obj,in)
            if coder.target('rtw')
                coder.ceval('MW_AudioPlayback_Write',...
                obj.AudioPlaybackHandle,...
                obj.DataTypeID,...
                coder.rref(in));
            end
        end

        function releaseImpl(obj)
            if coder.target('rtw')
                coder.ceval('MW_AudioPlayback_Terminate',...
                obj.AudioPlaybackHandle);
            end
        end
    end

    methods(Static)
        function name=getDescriptiveName()
            name='Audio Playback';
        end

        function b=isSupportedContext(context)
            b=context.isCodeGenTarget('rtw');
        end

        function updateBuildInfo(buildInfo,context)
            if context.isCodeGenTarget('rtw')
                socProcDir=soc.internal.getRootDir;
                linuxHSPDir=soc.embeddedlinux.internal.getRootDir;
                linuxSharedDir=realtime.internal.getLinuxRoot;
                addIncludePaths(buildInfo,fullfile(socProcDir,'include'));
                addIncludePaths(buildInfo,fullfile(linuxHSPDir,'include'));
                addIncludePaths(buildInfo,fullfile(linuxSharedDir,'include'));
                addIncludeFiles(buildInfo,'MW_alsa_audio.h');
                addIncludeFiles(buildInfo,'mw_soc_audioplayback.h');
                addSourceFiles(buildInfo,'MW_alsa_audio.c',...
                fullfile(linuxSharedDir,'src'),'SkipForSil');
                addSourceFiles(buildInfo,'mw_soc_audioplayback.c',...
                fullfile(linuxHSPDir,'src'),'SkipForSil');
                addDefines(buildInfo,sprintf('AUDIOPLAYBACK_BLOCK_INCLUDED=1'));
                addLinkFlags(buildInfo,{'-lasound'},'SkipForSil');
            end
        end
    end

    methods(Static,Access=protected)
        function simMode=getSimulateUsingImpl(~)
            simMode='Interpreted execution';
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end
end
