


function sz=resultSize(param,stride,imgSize,origImgSize,bcc,cc)


    padding=param.paddingMode;
    stridePhase=param.stridePhase;
    dilation=param.dilationMode;
    origOpSizeValue=param.origOpSizeValue;


    if(all(size(dilation)==1))

        dilation=[dilation;dilation];
    elseif(size(dilation,1)==1)
        dilation=dilation';
    end

    stride=[stride;stride];
    if(numel(padding)==1)
        padding=ones(1,4)*padding;
    end



    if any(origImgSize>imgSize)
        padding=zeros(1,4);
    end






    origOpSizeValue=origOpSizeValue(1:2);




    dilatedOpSize=(origOpSizeValue-1).*dilation+[1;1];

    paddedImgSize=imgSize+[padding(2)+padding(1);padding(4)+padding(3)];



    if any(paddedImgSize<dilatedOpSize)


        memorysize=bcc.conv.inputMemDepthLimit;
        printmemsize=[memorysize(2),memorysize(3),memorysize(1)];

        n=dnnfpga.processorbase.reverseCalcMemSize(paddedImgSize,dilatedOpSize,param,bcc,cc);
        expectedMemorySize=[n,n,memorysize(1)];

        msg=message("dnnfpga:config:ImageBiggerThanMemory",...
        mat2str(printmemsize),mat2str(expectedMemorySize),param.phase);
        error(msg);
    end

    assert(all(stridePhase==0));





    sz=floor((paddedImgSize-dilatedOpSize)./stride+1);
end

