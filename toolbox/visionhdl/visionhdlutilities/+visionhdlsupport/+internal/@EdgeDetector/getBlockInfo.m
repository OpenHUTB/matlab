function blockInfo=getBlockInfo(this,hC)




    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;

        blockInfo.Method=sysObjHandle.Method;
        blockInfo.BinaryImageOutputPort=sysObjHandle.BinaryImageOutputPort;
        blockInfo.GradientComponentOutputPorts=sysObjHandle.GradientComponentOutputPorts;

        blockInfo.ThresholdSource=sysObjHandle.ThresholdSource;
        blockInfo.Threshold=sysObjHandle.Threshold;
        blockInfo.LineBufferSize=sysObjHandle.LineBufferSize;
        blockInfo.RoundingMethod=sysObjHandle.RoundingMethod;
        blockInfo.OverflowAction=sysObjHandle.OverflowAction;
        blockInfo.GradientDataType=sysObjHandle.GradientDataType;
        blockInfo.CustomGradientDataType=sysObjHandle.CustomGradientDataType;

        if strcmp(sysObjHandle.ThresholdSource,'Input port')&&sysObjHandle.BinaryImageOutputPort
            blockInfo.numInputPorts=3;
            blockInfo.Threshold=0;
        else
            blockInfo.numInputPorts=2;
            blockInfo.Threshold=sysObjHandle.Threshold;
        end

        if sysObjHandle.BinaryImageOutputPort&&sysObjHandle.GradientComponentOutputPorts
            blockInfo.numOutputPorts=4;
        elseif~sysObjHandle.BinaryImageOutputPort&&sysObjHandle.GradientComponentOutputPorts
            blockInfo.numOutputPorts=3;
        elseif sysObjHandle.BinaryImageOutputPort&&~sysObjHandle.GradientComponentOutputPorts
            blockInfo.numOutputPorts=2;
        end


        if strcmp(sysObjHandle.Method,'Roberts')
            blockInfo.KernelHeight=2;
        else
            blockInfo.KernelHeight=3;
        end
        blockInfo.KernelWidth=blockInfo.KernelHeight;
        blockInfo.MaxLineSize=sysObjHandle.LineBufferSize;
        pmethod=sysObjHandle.PaddingMethod;
        blockInfo.PaddingMethodString=pmethod;


    else
        bfp=hC.Simulinkhandle;

        blockInfo.Method=get_param(bfp,'Method');
        blockInfo.BinaryImageOutputPort=strcmp(get_param(bfp,'BinaryImageOutputPort'),'on');
        blockInfo.GradientComponentOutputPorts=strcmp(get_param(bfp,'GradientComponentOutputPorts'),'on');

        blockInfo.ThresholdSource=get_param(bfp,'ThresholdSource');
        blockInfo.LineBufferSize=this.hdlslResolve('LineBufferSize',bfp);
        blockInfo.RoundingMethod=get_param(bfp,'RoundingMode');

        if strcmp(get_param(bfp,'OverflowMode'),'off')
            blockInfo.OverflowAction='Wrap';
        else
            blockInfo.OverflowAction='Saturate';
        end


        outputDTStr=get_param(bfp,'GradientDataTypeStr');
        if strcmpi(outputDTStr,'Inherit: Inherit via internal rule')||...
            strcmpi(outputDTStr,'Full precision')
            blockInfo.GradientDataType='Full precision';
            blockInfo.CustomGradientDataType=[];
        elseif strcmpi(outputDTStr,'Inherit: Same as first input')
            blockInfo.GradientDataType='Same as first input';
            blockInfo.CustomGradientDataType=[];
        else
            blockInfo.GradientDataType='Custom';
            blockInfo.CustomGradientDataType=this.hdlslResolve('GradientDataTypeStr',bfp);
        end

        if strcmp(get_param(bfp,'ThresholdSource'),'Input port')&&blockInfo.BinaryImageOutputPort
            blockInfo.numInputPorts=3;
            blockInfo.Threshold=0;
        else
            blockInfo.numInputPorts=2;
            blockInfo.Threshold=this.hdlslResolve('Threshold',bfp);
        end

        if blockInfo.BinaryImageOutputPort&&blockInfo.GradientComponentOutputPorts
            blockInfo.numOutputPorts=4;
        elseif~blockInfo.BinaryImageOutputPort&&blockInfo.GradientComponentOutputPorts
            blockInfo.numOutputPorts=3;
        elseif blockInfo.BinaryImageOutputPort&&~blockInfo.GradientComponentOutputPorts
            blockInfo.numOutputPorts=2;
        end


        if strcmp(get_param(bfp,'Method'),'Roberts')
            blockInfo.KernelHeight=2;
        else
            blockInfo.KernelHeight=3;
        end
        blockInfo.KernelWidth=blockInfo.KernelHeight;
        blockInfo.MaxLineSize=this.hdlslResolve('LineBufferSize',bfp);

        pmethod=get_param(bfp,'PaddingMethod');
        blockInfo.PaddingMethodString=pmethod;


    end


    gainParam=this.getImplParams('ConstMultiplierOptimization');
    OptimMode=0;
    if~isempty(gainParam)
        if strcmpi(gainParam,'none')
            OptimMode=0;
        elseif strcmpi(gainParam,'csd')
            OptimMode=1;
        elseif strcmpi(gainParam,'fcsd')
            OptimMode=2;
        elseif strcmpi(gainParam,'auto')
            OptimMode=3;
        end
    end
    blockInfo.gainOptimMode=OptimMode;
    blockInfo.gainMode=3;
