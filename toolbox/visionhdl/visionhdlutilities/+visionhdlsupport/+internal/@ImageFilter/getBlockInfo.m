function blockInfo=getBlockInfo(this,hC)
























    if isa(hC,'hdlcoder.sysobj_comp')


        sysObjHandle=hC.getSysObjImpl;

        coeffFromPort=strcmpi(sysObjHandle.CoefficientsSource,'Input port');
        blockInfo.coeffFromPort=coeffFromPort;
        if~coeffFromPort
            blockInfo.Coefficients=sysObjHandle.Coefficients;
        else
            blockInfo.Coefficients=getPortCoeff(hC,7);
        end

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


    else
        bfp=hC.Simulinkhandle;

        coeffFromPort=strcmpi(get_param(bfp,'CoefficientsSource'),'Input port');
        blockInfo.coeffFromPort=coeffFromPort;





        if~coeffFromPort
            blockInfo.Coefficients=this.hdlslResolve('Coefficients',bfp);
        else
            blockInfo.Coefficients=getPortCoeff(hC,3);
        end

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

        if~coeffFromPort

            coeffDTStr=get_param(bfp,'CoeffDataTypeStr');

            if strcmpi(coeffDTStr,'Inherit: Same as first input')
                blockInfo.CoefficientsDataType=1;
                blockInfo.CustomCoefficientsDataType=[];
            else
                blockInfo.CoefficientsDataType=2;
                blockInfo.CustomCoefficientsDataType=this.hdlslResolve('CoeffDataTypeStr',bfp);
            end
        else
            blockInfo.CoefficientsDataType=1;
            blockInfo.CustomCoefficientsDataType=[];
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

    end


    [blockInfo.KernelHeight,blockInfo.KernelWidth]=size(blockInfo.Coefficients);

end

function c=getPortCoeff(hC,idx)



    sig=hC.PirInputSignals(idx);
    vecSize=hdlsignalvector(sig);
    if strcmpi(vecSize,'Matrix')
        vecSize=sig.Type.Dimensions;
    end
    s=hdlsignalsizes(sig);
    c=fi(zeros(vecSize),s(3),s(1),s(2));

end
