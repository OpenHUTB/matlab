function[xy2,rxy2,wxy2]=computeAddresses(resultAddr,padding,stride,stridePhase,dilation)
%#codegen


    coder.allowpcode('plain');

    inputAddr=zeros(1,3*3);





    xy0=zeros(3,3,2);
    rxy0=zeros(3,3,2);
    wxy0=zeros(3,3,2);
    rx=resultAddr(1);
    ry=resultAddr(2);
    for ix=0:3-1
        for iy=0:3-1
            x=dnnfpga.convcontroller2.resolvePaddingStrideDilation(rx,ix,padding(1),stride(1),stridePhase(1),dilation(1));
            y=dnnfpga.convcontroller2.resolvePaddingStrideDilation(ry,iy,padding(3),stride(2),stridePhase(2),dilation(2));
            wAddr.x=ix;
            wAddr.y=iy;
            ibz.x=floor(x/3);
            ibz.y=floor(y/3);
            ibz.rx=x;
            ibz.ry=y;



            xy0(ix+1,iy+1,1)=ibz.x;
            xy0(ix+1,iy+1,2)=ibz.y;
            rxy0(ix+1,iy+1,1)=ibz.rx;
            rxy0(ix+1,iy+1,2)=ibz.ry;
            wxy0(ix+1,iy+1,1)=wAddr.x;
            wxy0(ix+1,iy+1,2)=wAddr.y;
        end
    end

    ibx=zeros(1,3);
    for ix=0:3-1
        x=dnnfpga.convcontroller2.resolvePaddingStrideDilation(rx,ix,padding(1),stride(1),stridePhase(1),dilation(1));
        ibx(ix+1)=mod(x,3);
    end

    iby=zeros(1,3);
    for iy=0:3-1
        y=dnnfpga.convcontroller2.resolvePaddingStrideDilation(ry,iy,padding(3),stride(2),stridePhase(2),dilation(2));
        iby(iy+1)=mod(y,3);
    end

    xy1=xy0;
    rxy1=rxy0;
    wxy1=wxy0;
    for ix=0:3-1
        for iy=0:3-1

            xy1(ibx(ix+1)+1,iy+1,1)=xy0(ix+1,iy+1,1);
            xy1(ibx(ix+1)+1,iy+1,2)=xy0(ix+1,iy+1,2);
            rxy1(ibx(ix+1)+1,iy+1,1)=rxy0(ix+1,iy+1,1);
            rxy1(ibx(ix+1)+1,iy+1,2)=rxy0(ix+1,iy+1,2);
            wxy1(ibx(ix+1)+1,iy+1,1)=wxy0(ix+1,iy+1,1);
            wxy1(ibx(ix+1)+1,iy+1,2)=wxy0(ix+1,iy+1,2);
        end
    end

    xy2=xy1;
    rxy2=rxy1;
    wxy2=wxy1;
    for ix=0:3-1
        for iy=0:3-1

            xy2(ix+1,iby(iy+1)+1,1)=xy1(ix+1,iy+1,1);
            xy2(ix+1,iby(iy+1)+1,2)=xy1(ix+1,iy+1,2);
            rxy2(ix+1,iby(iy+1)+1,1)=rxy1(ix+1,iy+1,1);
            rxy2(ix+1,iby(iy+1)+1,2)=rxy1(ix+1,iy+1,2);
            wxy2(ix+1,iby(iy+1)+1,1)=wxy1(ix+1,iy+1,1);
            wxy2(ix+1,iby(iy+1)+1,2)=wxy1(ix+1,iy+1,2);
        end
    end










end
