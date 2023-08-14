classdef AudioCapture<matlab.System&coder.ExternalDependency




%#codegen

    properties(Nontunable)
        DataType='int16'
        NumberOfChannels=2
        SamplesPerFrame=4410
        SampleTime=-1
        BlockID=''
    end

    properties(Access=private)
AudioCaptureParams
AudioCaptureHandle
DataTypeInBytes
DataTypeID
    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=0;
        end

        function num=getNumOutputsImpl(~)
            num=1;
        end
    end

    methods
        function obj=AudioCapture(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)
        function stVal=getSampleTimeImpl(obj)
            if obj.SampleTime==-1
                stVal=createSampleTime(obj,'Type','Inherited');
            else
                stVal=createSampleTime(obj,'Type','Discrete',...
                'SampleTime',obj.SampleTime);
            end
        end

        function flag=allowModelReferenceDiscreteSampleTimeInheritanceImpl(~)
            flag=true;
        end

        function validatePropertiesImpl(obj)
            switch obj.DataType
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

        function out=isOutputFixedSizeImpl(~)
            out=true;
        end

        function out=isOutputComplexImpl(~)
            out=false;
        end

        function out=getOutputSizeImpl(obj)
            out=obj.NumberOfChannels*obj.SamplesPerFrame;
        end

        function out=getOutputDataTypeImpl(obj)
            out=obj.DataType;
        end

        function setupImpl(obj)
            coder.extrinsic('codertarget.peripherals.utils.getPeripheralDataStructType');
            if coder.target('rtw')
                coder.cinclude('mw_soc_audiocapture.h');
                str=coder.const(...
                codertarget.peripherals.utils.getPeripheralDataStructType('AudioCapture'));
                coder.ceval("extern "+str+" "+obj.BlockID+";//");
                str=coder.const(obj.BlockID);
                blockCustParams=coder.opaque('MW_Void_Ptr_T',...
                coder.const("(MW_Void_Ptr_T)"+"&"+str),...
                'HeaderFile','mw_soc_drv_generic.h');
                blockParamsLoc=struct;
                coder.cstructname(blockParamsLoc,...
                'MW_AudioCapture_Params_T','extern',...
                'HeaderFile','mw_soc_audiocapture.h');
                blockParamsLoc.dataTypeID=obj.DataTypeID;
                blockParamsLoc.numChannels=obj.NumberOfChannels;
                blockParamsLoc.samplesPerFrame=obj.SamplesPerFrame;
                obj.AudioCaptureParams=blockParamsLoc;
                obj.AudioCaptureHandle=coder.opaque(...
                'MW_Void_Ptr_T',...
                'HeaderFile',...
                'mw_soc_drv_generic.h');
                obj.AudioCaptureHandle=coder.ceval(...
                'MW_AudioCapture_Init',...
                coder.ref(obj.AudioCaptureParams),...
                blockCustParams);
            end
        end

        function out=stepImpl(obj)
            out=zeros(obj.NumberOfChannels*obj.SamplesPerFrame,1,obj.DataType);
            if coder.target('rtw')
                coder.ceval('MW_AudioCapture_Read',...
                obj.AudioCaptureHandle,...
                obj.DataTypeID,...
                coder.wref(out));
            end
        end
        function releaseImpl(obj)
            if coder.target('rtw')
                coder.ceval('MW_AudioCapture_Terminate',obj.AudioCaptureHandle);
            end
        end
    end

    methods(Static)
        function name=getDescriptiveName()
            name='Audio Capture';
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
                addIncludeFiles(buildInfo,'mw_soc_audiocapture.h');
                addSourceFiles(buildInfo,'MW_alsa_audio.c',...
                fullfile(linuxSharedDir,'src'),'SkipForSil');
                addSourceFiles(buildInfo,'mw_soc_audiocapture.c',...
                fullfile(linuxHSPDir,'src'),'SkipForSil');
                addDefines(buildInfo,sprintf('AUDIOCAPTURE_BLOCK_INCLUDED=1'));
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
