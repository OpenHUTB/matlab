function[doneOut,zAddr,rtzOut,firstWrite,finalWrite,rtzSel,rtWeOut,dwx,dwy,wValid,mpwValid,r,c]=...
    compute(start,tileAddr,xyIn,rxyIn,dwInit,drInit,dzInit,rzLimitInit,...
    firstWritePos,finalWriteSize,resultSizeInit,resultSizeDivByOpWInit,imgSize,mpOpSize,imgSizeDivByOpW,padding,stride,dilation,...
    zAddrW,imgAddrW,imgSizeLimit,wSizeLimit,zSizeLimit,dwLimit,drLimit,dzLimit)
%#codegen







    coder.allowpcode('plain');






    xyInT=reshape(xyIn,[3,3,2]);
    rxyInT=reshape(rxyIn,[3,3,2]);

    persistent resultSize;
    persistent resultSizeDivByOpW;
    persistent xy0;
    persistent rxy0;
    persistent xy;
    persistent rxy;
    persistent rzLimitx0;
    persistent rzLimity0;
    persistent rzLimitx;
    persistent rzLimity;
    persistent dw;
    persistent dr;
    persistent dz;
    persistent dwxINT;
    persistent dwyINT;
    persistent rtx;
    persistent rty;
    persistent rtz;
    persistent rtxMod;
    persistent rtyMod;
    persistent rtxQuo;
    persistent rtyQuo;
    persistent rtWe;
    persistent done;
    persistent running;

    if(isempty(running))



        resultSize=fi([0;0],0,imgAddrW,0);
        resultSizeDivByOpW=fi([0;0],0,zAddrW,0);
        xy0=fi(zeros(3,3,2),1,zAddrW+1,0);
        rxy0=fi(zeros(3,3,2),1,imgAddrW+1,0);
        xy=fi(zeros(3,3,2),1,zAddrW+1,0);
        rxy=fi(zeros(3,3,2),1,imgAddrW+1,0);
        rzLimitx0=fi(0,1,imgAddrW+1,0);
        rzLimity0=fi(0,1,imgAddrW+1,0);
        rzLimitx=fi(0,1,imgAddrW+1,0);
        rzLimity=fi(0,1,imgAddrW+1,0);
        dw=fi(0,0,ceil(log2(dwLimit)),0);
        dr=fi(0,0,ceil(log2(drLimit)),0);
        dz=fi(0,0,ceil(log2(dzLimit)),0);
        dwxINT=fi(0,0,ceil(log2(dwLimit))+1,0);
        dwyINT=fi(0,0,ceil(log2(dwLimit))+1,0);
        rtx=fi(0,0,imgAddrW,0);
        rty=fi(0,0,imgAddrW,0);
        rtz=fi(zeros(3,3),0,zAddrW*2,0);
        rtxMod=fi(0,0,ceil(log2(3)),0);
        rtyMod=fi(0,0,ceil(log2(3)),0);
        rtxQuo=fi(0,0,zAddrW,0);
        rtyQuo=fi(0,0,zAddrW,0);
        rtWe=fi(zeros(3,3),0,1,0);
        done=false;
        running=false;
    end


    doneOut=done;
    [zAddrT,wValidT,mpwValidT]=convertOpAdddr(tileAddr,xy,rxy,imgSize,imgSizeDivByOpW,zAddrW,imgAddrW,mpOpSize);

    rtzOut=rtyQuo+rtxQuo*resultSizeDivByOpW(2);
    rtzSel=rtxMod+rtyMod*3;
    rtWeOut=reshape(rtWe,[3*3,1])&running;
    zAddr=reshape(zAddrT,[3*3,1]);
    wValid=reshape(wValidT,[1,3*3]);
    mpwValid=reshape(mpwValidT,[1,3*3]);
    r=reshape(rxy(:,:,1),[3*3,1]);
    c=reshape(rxy(:,:,2),[3*3,1]);

    rtAddr=fi(rtx*resultSize(2)+rty,0,ceil(log2(prod(imgSizeLimit))),0);
    dwy=dwyINT;
    dwx=dwxINT;

    firstWrite=(rtx>=firstWritePos(1)&&rtx<firstWritePos(2)&&rty>=firstWritePos(3)&&rty<firstWritePos(4));
    finalWrite=(rtx<finalWriteSize(1)&&rty<finalWriteSize(2));


    if(start&&~running)
        resultSize=resultSizeInit;
        resultSizeDivByOpW=resultSizeDivByOpWInit;
        xy0=xyInT;
        rxy0=rxyInT;
        xy=xyInT;
        rxy=rxyInT;
        rzLimitx0=rzLimitInit(1);
        rzLimity0=rzLimitInit(2);
        rzLimitx=rzLimitInit(1);
        rzLimity=rzLimitInit(2);
        dw=dwInit;
        dr=drInit;
        dz=dzInit;
        dwxINT=fi(0,0,ceil(log2(dwLimit))+1,0);
        dwyINT=fi(0,0,ceil(log2(dwLimit))+1,0);
        rtx=fi(0,0,imgAddrW,0);
        rty=fi(0,0,imgAddrW,0);
        rtz=fi(zeros(3,3),0,zAddrW*2,0);
        rtxMod=fi(0,0,ceil(log2(3)),0);
        rtyMod=fi(0,0,ceil(log2(3)),0);
        rtxQuo=fi(0,0,zAddrW,0);
        rtyQuo=fi(0,0,zAddrW,0);
        rtWe=fi(zeros(3,3),0,1,0);
        rtWe(1,1)=fi(1,0,1,0);
        done=false;
        running=true;
    else
        if(running)


            rzLimity=fi(rzLimity+stride,1,imgAddrW+1,0);
            if(rty<fi(resultSize(2)-1,0,imgAddrW,0))






                [xy,rxy]=moveOp(xy,rxy,0,1,dr,dz,rzLimitx,rzLimity,dilation,zAddrW,imgAddrW);
                [rtz,rtWe]=moveRtz(rtz,rtWe,rtxMod,0,zAddrW);


                rty=fi(rty+1,0,imgAddrW,0);


                if(rtyMod==3-1)
                    rtyMod=fi(0,0,ceil(log2(3)),0);
                    rtyQuo=fi(rtyQuo+1,0,zAddrW,0);
                else
                    rtyMod=fi(rtyMod+1,0,ceil(log2(3)),0);
                end


                dwyINT=fi(dwyINT+dw,0,ceil(log2(dwLimit))+1,0);
                if dwyINT>=3
                    dwyINT=fi(dwyINT-3,0,ceil(log2(dwLimit))+1,0);
                end
            else


                rzLimitx=fi(rzLimitx+stride,1,imgAddrW+1,0);





                [xy,rxy]=moveOp(xy,rxy,1,1,dr,dz,rzLimitx,rzLimity,dilation,zAddrW,imgAddrW);
                rzLimity=rzLimity0;



                [xy,rxy]=resetOp(xy0,rxy0,xy,rxy,0,1);
                [rtz,rtWe]=moveRtz(rtz,rtWe,rtxMod,1,zAddrW);


                rty=fi(0,0,imgAddrW,0);
                rtyMod=fi(0,0,ceil(log2(3)),0);
                rtyQuo=fi(0,0,zAddrW,0);


                dwyINT=fi(0,0,ceil(log2(dwLimit))+1,0);


                if(rtx<fi(resultSize(1)-1,0,imgAddrW,0))
                    rtx=fi(rtx+1,0,imgAddrW,0);
                    if(rtxMod==3-1)
                        rtxMod=fi(0,0,ceil(log2(3)),0);
                        rtxQuo=fi(rtxQuo+1,0,zAddrW,0);
                    else
                        rtxMod=fi(rtxMod+1,0,ceil(log2(3)),0);
                    end

                    dwxINT=fi(dwxINT+dw,0,ceil(log2(dwLimit))+1,0);
                    if dwxINT>=3
                        dwxINT=fi(dwxINT-3,0,ceil(log2(dwLimit))+1,0);
                    end
                else

                    dwxINT=fi(0,0,ceil(log2(dwLimit))+1,0);
                    done=true;
                    running=false;
                end
            end
        end
    end
end

function[xyOut,rxyOut]=moveOp(xy,rxy,dx,dy,dr,dz,rzLimitx,rzLimity,dilation,zAddrW,imgAddrW)
    assert(dx<=2&&dx>=0);
    assert(dy<=2&&dy>=0);
    xyOut=fi(zeros(3,3,2),1,zAddrW+1,0);
    rxyOut=fi(zeros(3,3,2),1,imgAddrW+1,0);
    for ibx=0:3-1
        for iby=0:3-1
            [rxyOut(ibx+1,iby+1,1),xyOut(ibx+1,iby+1,1)]=...
            updateR(rxy(ibx+1,iby+1,1),...
            xy(ibx+1,iby+1,1),...
            dx,dr,dz,...
            rzLimitx,dilation,...
            zAddrW,imgAddrW);
            [rxyOut(ibx+1,iby+1,2),xyOut(ibx+1,iby+1,2)]=...
            updateR(rxy(ibx+1,iby+1,2),...
            xy(ibx+1,iby+1,2),...
            dy,dr,dz,...
            rzLimity,dilation,...
            zAddrW,imgAddrW);
        end
    end
end

function[rxOut,xOut]=updateR(rxIn,xIn,dx,dr,dz,rxLimit,dilation,zAddrW,imgAddrW)
    rx=rxIn+dx*dr;
    x=xIn+dx*dz;
    if(rx>=rxLimit)
        rxOut=fi(rx-3*dilation,1,imgAddrW+1,0);
        xOut=fi(x-dilation,1,zAddrW+1,0);
    else
        rxOut=fi(rx,1,imgAddrW+1,0);
        xOut=fi(x,1,zAddrW+1,0);
    end
end

function[xy,rxy]=resetOp(xy0,rxy0,xy,rxy,dx,dy)
    for ibx=0:3-1
        for iby=0:3-1
            if(dx)
                xy(ibx+1,iby+1,1)=xy0(ibx+1,iby+1,1);
                rxy(ibx+1,iby+1,1)=rxy0(ibx+1,iby+1,1);
            end
            if(dy)
                xy(ibx+1,iby+1,2)=xy0(ibx+1,iby+1,2);
                rxy(ibx+1,iby+1,2)=rxy0(ibx+1,iby+1,2);
            end
        end
    end
end

function[rtz,rtWe]=moveRtz(rtz,rtWe,rtxMod,dx,zAddrW)
    initWe=fi([0,0,1;...
    1,0,0;...
    0,1,0]);
    rtz=fi(rtz+rtWe,0,zAddrW*2,0);
    rtWeT=fi(zeros(3,3),0,1,0);
    if(dx==0)
        for i=0:3-2
            rtWeT(:,i+1+1)=rtWe(:,i+1);
        end
        rtWeT(:,0+1)=rtWe(:,3-1+1);
    else
        rtWeT=fi(zeros(3,3),0,1,0);
        rtWeT(:,1)=initWe(:,rtxMod+1);
    end
    rtWe=rtWeT;
end

function[zAddr,wValid,mpwValid]=convertOpAdddr(tileAddr,xy,rxy,imgSize,imgSizeDivByOpW,zAddrW,imgAddrW,mpOpSize)







    zAddr=fi(zeros(3,3),1,zAddrW*2+1,0);
    wValid=fi(zeros(3,3),0,1,0);
    mpwValid=fi(zeros(3,3),0,1,0);
    for ibx=0:3-1
        for iby=0:3-1
            zIdx=(ibx*3+iby)*2;
            wIdx=zIdx+1;
            ibz=fi(xy(ibx+1,iby+1,2)+xy(ibx+1,iby+1,1)*imgSizeDivByOpW(2),1,zAddrW*2+1,0);
            rxyX=fi(rxy(ibx+1,iby+1,1)+tileAddr(1)*3,1,imgAddrW+1,0);
            rxyY=fi(rxy(ibx+1,iby+1,2)+tileAddr(2)*3,1,imgAddrW+1,0);
            if(rxyX<0||rxyX>=imgSize(1)||...
                rxyY<0||rxyY>=imgSize(2))
                w=false;
            else
                w=true;
            end
            mpwX=fi(ibx+tileAddr(1)*3,1,imgAddrW+1,0);
            mpwY=fi(iby+tileAddr(2)*3,1,imgAddrW+1,0);
            if(mpwX>=mpOpSize(1)||...
                mpwY>=mpOpSize(2))
                mpw=false;
            else
                mpw=true;
            end
            zAddr(ibx+1,iby+1)=ibz;
            wValid(ibx+1,iby+1)=w;
            mpwValid(ibx+1,iby+1)=mpw;
        end
    end
end
























































