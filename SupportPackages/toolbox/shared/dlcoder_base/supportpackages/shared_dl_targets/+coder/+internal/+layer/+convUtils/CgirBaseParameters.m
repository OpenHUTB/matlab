classdef(Abstract)CgirBaseParameters
























%#codegen

    properties
        InputChannelBlockSize(1,1){mustBeInteger,mustBePositive}=16
        InputChannelMiniblockSize(1,1){mustBeInteger,mustBePositive}=16
        OutputChannelBlockSize(1,1){mustBeInteger,mustBePositive}=16
        OutputHeightBlockSize(1,1){mustBeInteger,mustBePositive}=7
        SimdWidth(1,1){mustBeInteger,mustBeGreaterThanOrEqual(SimdWidth,-1),mustBeNonzero}=-1
        AllowMultiThreading(1,1){mustBeA(AllowMultiThreading,{'logical'})}=true;
        MaxMinIntrinsic(1,1){mustBeInteger,mustBeGreaterThanOrEqual(MaxMinIntrinsic,0)}=0;
    end

    methods(Hidden,Sealed)


        function obj=setSimdWidthToLargest(obj,dataType,buildContext)




            largestSimdWidth=dltargets.internal.getLargestSIMDWidth('vload',dataType,...
            buildContext);
            obj.SimdWidth=largestSimdWidth;
            obj=updateOutputChannelBlockSize(obj);
        end

        function obj=updateInputChannelBlockSize(obj)
            obj.InputChannelBlockSize=dltargets.internal.roundUp(obj.InputChannelBlockSize,...
            obj.InputChannelMiniblockSize);
        end

        function obj=updateOutputChannelBlockSize(obj)
            obj.OutputChannelBlockSize=dltargets.internal.roundUp(obj.OutputChannelBlockSize,...
            obj.SimdWidth);
        end
    end

    methods(Static,Hidden)


        function optOut=matlabCodegenLowerToStruct(~)
            optOut=true;
        end
    end
end
