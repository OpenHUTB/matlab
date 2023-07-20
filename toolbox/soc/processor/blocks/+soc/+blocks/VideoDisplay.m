classdef VideoDisplay<matlab.System&coder.ExternalDependency




%#codegen
    properties(Nontunable)
        PixelFormat='RGB';
        BlockID='';
    end

    properties(Nontunable,Hidden)
        PixelFormatID=int32(1);
    end


    properties(Access=private)
        VideoDisplayParams;
        VideoDisplayHandle;
        DataTypeInBytes;
        DataTypeID;
    end

    properties(Hidden)
        displayId=int32(-1);
    end

    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=3;
        end

        function num=getNumOutputsImpl(~)
            num=0;
        end

        function flag=allowModelReferenceDiscreteSampleTimeInheritanceImpl(~)
            flag=true;
        end
    end

    methods
        function obj=VideoDisplay(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
        function ret=get.PixelFormatID(obj)
            ret=~isequal(obj.PixelFormat,'RGB')+1;
        end
    end

    methods(Access=protected)
        function validateInputsImpl(obj,~)
            obj.DataTypeInBytes=1;
            obj.DataTypeID=MW_SOC_DataType.MW_UINT8;
        end

        function w=getImageWidth(obj)

            thisSize=propagatedInputSize(obj,1);
            w=thisSize(1);
        end

        function h=getImageHeight(obj)

            thisSize=propagatedInputSize(obj,1);
            h=thisSize(2);
        end

        function setupImpl(obj)
            coder.extrinsic('codertarget.peripherals.utils.getPeripheralDataStructType');
            display=int32(0);
            if coder.target('rtw')
                coder.cinclude('mw_soc_videodisplay.h');
                str=coder.const(...
                codertarget.peripherals.utils.getPeripheralDataStructType('VideoDisplay'));
                coder.ceval("extern "+str+" "+obj.BlockID+";//");
                str=coder.const(obj.BlockID);
                blockCustParams=coder.opaque('MW_Void_Ptr_T',...
                coder.const("(MW_Void_Ptr_T)"+"&"+str),...
                'HeaderFile','mw_soc_drv_generic.h');
                blockParamsLoc=struct;
                coder.cstructname(blockParamsLoc,...
                'MW_VideoDisplay_Params_T','extern',...
                'HeaderFile','mw_soc_videodisplay.h');
                blockParamsLoc.pixelFormat=obj.PixelFormatID;
                blockParamsLoc.imageWidth=obj.getImageWidth;
                blockParamsLoc.imageHeight=obj.getImageHeight;
                obj.VideoDisplayParams=blockParamsLoc;
                obj.VideoDisplayHandle=coder.opaque(...
                'MW_Void_Ptr_T',...
                'HeaderFile',...
                'mw_soc_videodisplay.h');
                obj.VideoDisplayHandle=coder.ceval(...
                'MW_VideoDisplay_Init',...
                coder.ref(obj.VideoDisplayParams),...
                blockCustParams);
                display=coder.ceval('MW_VideoDisplay_GetIndex');
                obj.displayId=display;
            end
        end

        function stepImpl(obj,in1,in2,in3)
            if coder.target('rtw')
                coder.ceval('MW_VideoDisplay_Write',...
                obj.VideoDisplayHandle,...
                coder.rref(in1),...
                coder.rref(in2),...
                coder.rref(in3),...
                obj.displayId);
            end
        end

        function releaseImpl(obj)
            if coder.target('rtw')
                coder.ceval('MW_VideoDisplay_Terminate',...
                obj.VideoDisplayHandle,...
                obj.displayId);
            end
        end
    end

    methods(Static)
        function name=getDescriptiveName()
            name='Video Display';
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
                addIncludeFiles(buildInfo,'MW_SDL2_video_display.h');
                addIncludeFiles(buildInfo,'mw_soc_videodisplay.h');
                addSourceFiles(buildInfo,'MW_SDL2_video_display.c',...
                fullfile(linuxSharedDir,'src'),'SkipForSil');
                addSourceFiles(buildInfo,'mw_soc_videodisplay.c',...
                fullfile(linuxHSPDir,'src'),'SkipForSil');
                addDefines(buildInfo,sprintf('VIDEODISPLAY_BLOCK_INCLUDED=1'));
                sdl2_linkflags='-I/usr/include/SDL2 -D_REENTRANT';
                addLinkFlags(buildInfo,{sdl2_linkflags},'SkipForSil');
                addLinkFlags(buildInfo,{'-lSDL2'},'SkipForSil');
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
