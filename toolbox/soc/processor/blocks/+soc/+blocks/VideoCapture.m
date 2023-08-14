classdef VideoCapture<matlab.System&coder.ExternalDependency




%#codegen

    properties(Nontunable)
        DataType='uint8'
        ImageWidth=160;
        ImageHeight=120;
        PixelFormat='RGB';
        SampleTime=-1;
        Out1NumElements=19200;
        Out2NumElements=19200;
        Out3NumElements=19200;
        BlockID='';
    end

    properties(Nontunable,Hidden)
        PixelFormatID=uint32(2);
    end


    properties(Access=private)
        VideoCaptureParams;
        VideoCaptureHandle;
        DataTypeInBytes;
        DataTypeID;
    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=0;
        end
        function num=getNumOutputsImpl(~)
            num=3;
        end
    end

    methods
        function obj=VideoCapture(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
        function ret=get.PixelFormatID(obj)
            ret=isequal(obj.PixelFormat,'RGB')+1;
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
            obj.DataTypeInBytes=1;
            obj.DataTypeID=MW_SOC_DataType.MW_UINT8;
        end
        function[out1,out2,out3]=isOutputFixedSizeImpl(~)
            out1=true;
            out2=true;
            out3=true;
        end
        function[out1,out2,out3]=isOutputComplexImpl(~)
            out1=false;
            out2=false;
            out3=false;
        end
        function[out1,out2,out3]=getOutputSizeImpl(obj)
            out1=[obj.Out1NumElements/obj.ImageHeight,obj.ImageHeight];
            out2=[obj.Out2NumElements/obj.ImageHeight,obj.ImageHeight];
            out3=[obj.Out3NumElements/obj.ImageHeight,obj.ImageHeight];
        end
        function[out1,out2,out3]=getOutputDataTypeImpl(~)
            out1='uint8';
            out2='uint8';
            out3='uint8';
        end
        function setupImpl(obj)
            coder.extrinsic('codertarget.peripherals.utils.getPeripheralDataStructType');
            coder.extrinsic('soc.blocks.getDeviceNumberForVideoCapture');
            if coder.target('rtw')
                coder.cinclude('mw_soc_videocapture.h');


                coder.ceval('getCameraList');
                status=uint8(0);
                deviceNum=coder.const(...
                soc.blocks.getDeviceNumberForVideoCapture(obj.BlockID));
                status=coder.ceval('validateResolution',uint8(deviceNum),...
                uint16(obj.ImageWidth),uint16(obj.ImageHeight));
                obj.VideoCaptureHandle=coder.opaque('MW_Void_Ptr_T',...
                'HeaderFile','mw_soc_drv_generic.h');

                strType=coder.const(...
                codertarget.peripherals.utils.getPeripheralDataStructType('VideoCapture'));
                coder.ceval("extern "+strType+" "+obj.BlockID+";//");
                str=coder.const(obj.BlockID);
                blockCustParams=coder.opaque('MW_Void_Ptr_T',...
                coder.const("(MW_Void_Ptr_T)"+"&"+str),...
                'HeaderFile','mw_soc_drv_generic.h');
                blockParamsLoc=struct;
                coder.cstructname(blockParamsLoc,...
                'MW_VideoCapture_Params_T','extern',...
                'HeaderFile','mw_soc_videocapture.h');
                blockParamsLoc.imageWidth=obj.ImageWidth;
                blockParamsLoc.imageHeight=obj.ImageHeight;
                blockParamsLoc.pixelFormat=obj.PixelFormatID;
                blockParamsLoc.sampleTime=obj.SampleTime;
                obj.VideoCaptureParams=blockParamsLoc;
                obj.VideoCaptureHandle=coder.ceval('MW_VideoCapture_Init',...
                coder.ref(obj.VideoCaptureParams),deviceNum,...
                blockCustParams);

            end
        end
        function[out1,out2,out3]=stepImpl(obj)
            coder.extrinsic('soc.blocks.getDeviceNumberForVideoCapture');
            out1=zeros(obj.Out1NumElements/obj.ImageHeight,obj.ImageHeight,...
            obj.DataType);
            out2=zeros(obj.Out2NumElements/obj.ImageHeight,obj.ImageHeight,...
            obj.DataType);
            out3=zeros(obj.Out3NumElements/obj.ImageHeight,obj.ImageHeight,...
            obj.DataType);
            if coder.target('rtw')
                deviceNumber=coder.const(...
                soc.blocks.getDeviceNumberForVideoCapture(obj.BlockID));
                coder.ceval('MW_VideoCapture_Read',...
                obj.VideoCaptureHandle,...
                deviceNumber,...
                coder.wref(out1),...
                coder.wref(out2),...
                coder.wref(out3));
            end
        end
        function releaseImpl(obj)
            coder.extrinsic('soc.blocks.getDeviceNumberForVideoCapture');
            if coder.target('rtw')
                deviceNumber=coder.const(...
                soc.blocks.getDeviceNumberForVideoCapture(obj.BlockID));
                coder.ceval('MW_VideoCapture_Terminate',...
                obj.VideoCaptureHandle,...
                deviceNumber);
            end
        end
    end

    methods(Static)
        function name=getDescriptiveName()
            name='Video Capture';
        end
        function ret=isSupportedContext(context)
            ret=context.isCodeGenTarget('rtw');
        end
        function updateBuildInfo(buildInfo,context)
            if context.isCodeGenTarget('rtw')
                socProcDir=soc.internal.getRootDir;
                linuxHSPDir=soc.embeddedlinux.internal.getRootDir;
                linuxSharedDir=realtime.internal.getLinuxRoot;
                addIncludePaths(buildInfo,fullfile(socProcDir,'include'));
                addIncludePaths(buildInfo,fullfile(linuxHSPDir,'include'));
                addIncludePaths(buildInfo,fullfile(linuxSharedDir,'include'));
                addIncludeFiles(buildInfo,'MW_v4l2_cam.h');
                addIncludeFiles(buildInfo,'MW_availableWebcam.h');
                addIncludeFiles(buildInfo,'mw_soc_videocapture.h');
                addSourceFiles(buildInfo,'MW_v4l2_cam.c',...
                fullfile(linuxSharedDir,'src'),'SkipForSil');
                addSourceFiles(buildInfo,'MW_availableWebcam.c',...
                fullfile(linuxSharedDir,'src'),'SkipForSil');
                addSourceFiles(buildInfo,'mw_soc_videocapture.c',...
                fullfile(linuxHSPDir,'src'),'SkipForSil');
                addDefines(buildInfo,sprintf('VIDEOCAPTURE_BLOCK_INCLUDED=1'));
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
