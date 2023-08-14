



function[resultSize,resultSizeDivByOpW,imgSizeDivByOpW,xy0,rxy0,wAddr0,dw,dr,dz,rzLimitOriginal]...
    =initCtrlDataUnpool(padding,stride,stridePhase,dilation,imgSize,origOpSizeValue,wSizeLimit,opW,unpoolRemainder)
    if(all(size(dilation)==1))

        dilation=[dilation;dilation];
    elseif(size(dilation,1)==1)
        dilation=dilation';
    end
    stride=[stride;stride];
    if(numel(padding)==1)
        padding=ones(1,4)*padding;
    end






    origOpSizeValue=origOpSizeValue(1:2);

    dilatedOpSize=origOpSizeValue+(dilation-1).*(origOpSizeValue-1);
    paddedImgSize=imgSize+[padding(2)+padding(1);padding(4)+padding(3)];


    resultSize=paddedImgSize.*dilatedOpSize+unpoolRemainder;
    resultSizeDivByOpW=ceil(resultSize/opW);
    imgSizeDivByOpW=ceil(imgSize/opW);



    [xy0,rxy0,wxy0]=dnnfpga.convcontroller2.computeAddresses([0,0],padding,stride,stridePhase,dilation);
    [xy1,rxy1,wxy1]=dnnfpga.convcontroller2.computeAddresses([1,1],padding,stride,stridePhase,dilation);

    dr=[rxy1(1,1,2)-rxy0(1,1,2),rxy1(1,2,2)-rxy0(1,2,2),rxy1(1,3,2)-rxy0(1,3,2)];
    dr=max(dr);
    dz=dr/3;

    dwT=[wxy1(1,1,2)-wxy0(1,1,2),wxy1(1,2,2)-wxy0(1,2,2),wxy1(1,3,2)-wxy0(1,3,2)];
    dwT1=mod(dwT,3);
    assert(isequal(dwT1,ones(1,3)*dwT1(1)));
    dw=dwT1(1);

    rzLimitOriginal=dnnfpga.convcontroller2.resolvePaddingStrideDilation(0,0,[padding(1);padding(3)],stride,stridePhase,dilation)+3*dilation;

    [~,~,wxy0]=dnnfpga.convcontroller2.computeAddresses([0,0],[padding(3),padding(4),padding(1),padding(2)],stride,flip(stridePhase),dilation);
    wAddr0=zeros(3,3);
    for ibx=0:3-1
        for iby=0:3-1
            wAddr0(ibx+1,iby+1)=wxy0(ibx+1,iby+1,2)+wxy0(ibx+1,iby+1,1)*3;
        end
    end
end
