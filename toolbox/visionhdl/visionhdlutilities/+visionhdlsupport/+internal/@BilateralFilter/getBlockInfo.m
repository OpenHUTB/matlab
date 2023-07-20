function blockInfo=getBlockInfo(this,hC)

























    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;

        blockInfo.SpatialStdDev=sysObjHandle.SpatialStdDev;
        blockInfo.IntensityStdDev=sysObjHandle.IntensityStdDev;

        pmethod=sysObjHandle.PaddingMethod;
        blockInfo.PaddingMethodString=pmethod;
        blockInfo.PaddingValue=0;
        if strcmpi(pmethod,'Constant')
            blockInfo.PaddingMethod=0;
            blockInfo.PaddingValue=sysObjHandle.PaddingValue;
        elseif strcmpi(pmethod,'Replicate')
            blockInfo.PaddingMethod=1;
        else
            blockInfo.PaddingMethod=2;
        end

        blockInfo.LineBufferSize=sysObjHandle.LineBufferSize;

        blockInfo.RoundingMethod=sysObjHandle.RoundingMethod;
        blockInfo.OverflowAction=sysObjHandle.OverflowAction;


        if strcmpi(sysObjHandle.CoefficientsDataType,'Same as first input')
            blockInfo.CoefficientsDataType=1;
            blockInfo.CustomCoefficientsDataType=[];
        else
            blockInfo.CoefficientsDataType=2;
            blockInfo.CustomCoefficientsDataType=sysObjHandle.CustomCoefficientsDataType;
        end

        if strcmpi(sysObjHandle.OutputDataType,'Same as first input')
            blockInfo.OutputDataType=1;
            blockInfo.CustomOutputDataType=[];
        elseif strcmpi(sysObjHandle.OutputDataType,'Full Precision')
            blockInfo.OutputDataType=2;
            blockInfo.CustomOutputDataType=[];
        else
            blockInfo.OutputDataType=3;
            blockInfo.CustomOutputDataType=sysObjHandle.CustomOutputDataType;
        end

        NeighborhoodSize=sysObjHandle.NeighborhoodSize;
        if strcmpi(NeighborhoodSize,'3x3')
            NSize=3;
        elseif strcmpi(NeighborhoodSize,'5x5')
            NSize=5;
        elseif strcmpi(NeighborhoodSize,'7x7')
            NSize=7;
        elseif strcmpi(NeighborhoodSize,'9x9')
            NSize=9;
        elseif strcmpi(NeighborhoodSize,'11x11')
            NSize=11;
        elseif strcmpi(NeighborhoodSize,'13x13')
            NSize=13;
        else
            NSize=15;
        end
        blockInfo.KernelHeight=NSize;
        blockInfo.KernelWidth=NSize;


    else
        bfp=hC.Simulinkhandle;

        blockInfo.SpatialStdDev=this.hdlslResolve('SpatialStdDev',bfp);
        blockInfo.IntensityStdDev=this.hdlslResolve('IntensityStdDev',bfp);

        pmethod=get_param(bfp,'PaddingMethod');
        blockInfo.PaddingMethodString=pmethod;
        blockInfo.PaddingValue=0;
        if strcmpi(pmethod,'Constant')
            blockInfo.PaddingMethod=0;
            blockInfo.PaddingValue=this.hdlslResolve('PaddingValue',bfp);
        elseif strcmpi(pmethod,'Replicate')
            blockInfo.PaddingMethod=1;
        else
            blockInfo.PaddingMethod=2;
        end

        blockInfo.LineBufferSize=this.hdlslResolve('LineBufferSize',bfp);

        blockInfo.RoundingMethod=get_param(bfp,'RoundingMode');
        blockInfo.OverflowAction=get_param(bfp,'OverflowMode');


        if strcmpi(blockInfo.OverflowAction,'off')
            blockInfo.OverflowAction='Wrap';
        else
            blockInfo.OverflowAction='Saturate';
        end


        coeffDTStr=get_param(bfp,'CoefficientsDataTypeStr');

        if strcmpi(coeffDTStr,'Inherit: Same as first input')
            blockInfo.CoefficientsDataType=1;
            blockInfo.CustomCoefficientsDataType=[];
        else
            blockInfo.CoefficientsDataType=2;
            blockInfo.CustomCoefficientsDataType=this.hdlslResolve('CoefficientsDataTypeStr',bfp);
        end


        outputDTStr=get_param(bfp,'OutputDataTypeStr');
        if strcmpi(outputDTStr,'Inherit: Inherit via internal rule')||...
            strcmpi(outputDTStr,'Full Precision')
            blockInfo.OutputDataType=2;
            blockInfo.CustomOutputDataType=[];
        elseif strcmpi(outputDTStr,'Inherit: Same as first input')
            blockInfo.OutputDataType=1;
            blockInfo.CustomOutputDataType=[];
        else
            blockInfo.OutputDataType=3;
            blockInfo.CustomOutputDataType=this.hdlslResolve('OutputDataTypeStr',bfp);
        end

        NeighborhoodSize=get_param(bfp,'NeighborhoodSize');
        if strcmpi(NeighborhoodSize,'3x3')
            NSize=3;
        elseif strcmpi(NeighborhoodSize,'5x5')
            NSize=5;
        elseif strcmpi(NeighborhoodSize,'7x7')
            NSize=7;
        elseif strcmpi(NeighborhoodSize,'9x9')
            NSize=9;
        elseif strcmpi(NeighborhoodSize,'11x11')
            NSize=11;
        elseif strcmpi(NeighborhoodSize,'13x13')
            NSize=13;
        else
            NSize=15;
        end
        blockInfo.KernelHeight=NSize;
        blockInfo.KernelWidth=NSize;

    end

end
