function outputSize=propagateConvLayerOutputSize(param)







    if(strcmp(param.type,'FPGA_Lrn2D'))
        outputSize=param.origImgSize;
    else

        origImgSize=param.origImgSize;
        origOpSizeValue=param.origOpSizeValue;
        strideSize=dnnfpga.convbase.resolveStrideMode(param.strideMode);
        if(isfield(param,'stridePhase'))
            stridePhase=[param.stridePhase;1];
        else
            stridePhase=0;
        end
        if(numel(param.paddingMode)==4)
            paddingMode=param.paddingMode;
        else
            assert(numel(param.paddingMode)==1);
            paddingMode=ones(4,1)*param.paddingMode;
        end
        if isfield(param,'unpoolRemainder')
            unpoolRemainder=[param.unpoolRemainder;0];
        else
            unpoolRemainder=[0;0;0];
        end
        if strcmp(param.type,'FPGA_Unpool2D')||strcmp(param.type,'FPGA_TransposedConv')
            assert(all(paddingMode==0));
            assert(all(stridePhase(1:2)==0));
            assert(all(strideSize==1));
            outputSize=floor((origImgSize-stridePhase)./strideSize).*origOpSizeValue+unpoolRemainder;
        else
            assert(all((origImgSize-origOpSizeValue+[paddingMode(1)+paddingMode(2);paddingMode(3)+paddingMode(4);1])>=0));
            outputSize=floor((origImgSize-origOpSizeValue+[paddingMode(1)+paddingMode(2);paddingMode(3)+paddingMode(4);1]-stridePhase)./strideSize)+1;
        end
    end
end

