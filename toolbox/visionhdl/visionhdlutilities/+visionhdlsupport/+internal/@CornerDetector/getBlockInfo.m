function blockInfo=getBlockInfo(this,hC)














    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;

        blockInfo.Method=sysObjHandle.Method;
        blockInfo.MinContrastSource=sysObjHandle.MinContrastSource;
        blockInfo.MinContrast=sysObjHandle.MinContrast;
        blockInfo.LineBufferSize=sysObjHandle.LineBufferSize;
        blockInfo.RoundingMethod=sysObjHandle.RoundingMethod;
        blockInfo.OverflowAction=sysObjHandle.OverflowAction;
        blockInfo.CustomOutputDataType=sysObjHandle.CustomOutputDataType;
        blockInfo.PaddingMethod=sysObjHandle.PaddingMethod;
        blockInfo.ThresholdSource=sysObjHandle.ThresholdSource;
        blockInfo.Threshold=sysObjHandle.Threshold;

        if strcmp(sysObjHandle.MinContrastSource,'Input port')&&~strcmp(sysObjHandle.Method,'Harris')
            blockInfo.numInputPorts=3;
            blockInfo.MinContrast=0;
        elseif strcmp(sysObjHandle.ThresholdSource,'Input port')&&strcmp(sysObjHandle.Method,'Harris')
            blockInfo.numInputPorts=3;
            blockInfo.Threshold=0;
        else
            blockInfo.numInputPorts=2;
        end

        blockInfo.numOutputPorts=1;

        switch blockInfo.Method
        case 'FAST 5 of 8'
            blockInfo.KernelHeight=3;
        case 'FAST 7 of 12'
            blockInfo.KernelHeight=5;
        case 'FAST 9 of 16'
            blockInfo.KernelHeight=7;
        otherwise
            blockInfo.KernelHeight=3;
        end
        blockInfo.KernelWidth=blockInfo.KernelHeight;
        blockInfo.MaxLineSize=sysObjHandle.LineBufferSize;

    else
        bfp=hC.Simulinkhandle;

        blockInfo.Method=get_param(bfp,'Method');
        switch blockInfo.Method
        case 'Harris'
            blockInfo.KernelHeight=3;
        case 'FAST 5 of 8'
            blockInfo.KernelHeight=3;
        case 'FAST 7 of 12'
            blockInfo.KernelHeight=5;
        case 'FAST 9 of 16'
            blockInfo.KernelHeight=7;
        end
        blockInfo.PaddingMethod=get_param(bfp,'PaddingMethod');

        blockInfo.MinContrastSource=get_param(bfp,'MinContrastSource');
        blockInfo.ThresholdSource=get_param(bfp,'ThresholdSource');

        blockInfo.LineBufferSize=this.hdlslResolve('LineBufferSize',bfp);
        blockInfo.RoundingMethod=get_param(bfp,'RoundingMode');

        if strcmp(get_param(bfp,'OverflowMode'),'off')
            blockInfo.OverflowAction='Wrap';
        else
            blockInfo.OverflowAction='Saturate';
        end


        outputDTStr=get_param(bfp,'OutputDataTypeStr');
        if strcmpi(outputDTStr,'Inherit: Inherit via internal rule')||...
            strcmpi(outputDTStr,'Full precision')
            blockInfo.OutputDataType='Full precision';
            blockInfo.CustomOutputDataType=[];
        elseif strcmpi(outputDTStr,'Inherit: Same as first input')
            blockInfo.OutputDataType='Same as first input';
            blockInfo.CustomOutputDataType=[];
        else
            blockInfo.OutputDataType='Custom';
            blockInfo.CustomOutputDataType=this.hdlslResolve('OutputDataTypeStr',bfp);
        end

        if strcmp(get_param(bfp,'MinContrastSource'),'Input port')&&~strcmp(blockInfo.Method,'Harris')
            blockInfo.numInputPorts=3;
            blockInfo.MinContrast=0;
        elseif strcmp(get_param(bfp,'ThresholdSource'),'Input port')&&strcmp(blockInfo.Method,'Harris')
            blockInfo.numInputPorts=3;
            blockInfo.Threshold=0;
        else
            blockInfo.numInputPorts=2;
            if strcmp(blockInfo.Method,'Harris')
                blockInfo.Threshold=this.hdlslResolve('Threshold',bfp);
            else
                blockInfo.MinContrast=this.hdlslResolve('MinContrast',bfp);
            end
        end

        blockInfo.KernelWidth=blockInfo.KernelHeight;
        blockInfo.MaxLineSize=blockInfo.LineBufferSize;
    end

