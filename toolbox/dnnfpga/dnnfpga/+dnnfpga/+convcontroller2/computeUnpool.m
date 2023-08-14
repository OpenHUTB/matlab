function[doneOut,zAddr,rtzOut,firstWrite,finalWrite,rtzSel,rSel,windx,...
    rtWeOut_,dwx_,dwy_,wValid,mpwValid,r,c,rtxModK_,rtyModK_,state]=...
    computeUnpool(start,firstWritePos,finalWriteSize,resultSizeInit,...
    resultSizeDivByOpWInit,imgSize,kernelSize,imgSizeDivByOpW,convMode,...
    weightCounterLimit,inputFeatureAddr,inputFeatureAddrMax,...
    zAddrW,imgAddrW,dwLimit,zKernelAddrW,unpoolKernelAddrW,...
    unpoolKernelDivByOpWAddrW,convIndexActsBurstLengthAddrW)

%#codegen
    coder.allowpcode('plain');








    persistent rty;
    persistent rtx;

    persistent rtyModK;
    persistent rtyQuoK;
    persistent rtxModK;
    persistent rtxQuoK;

    persistent ry;
    persistent rx;

    persistent ryMod;
    persistent y;
    persistent rxMod;
    persistent x;


    persistent py;
    persistent px;


    persistent rtyMod;
    persistent rtyQuo;
    persistent rtxMod;
    persistent rtxQuo;



    persistent rtyModKMod;
    persistent rtyModKQuo;
    persistent rtxModKMod;
    persistent rtxModKQuo;



    persistent pyMod;
    persistent pyQuo;
    persistent pxMod;
    persistent pxQuo;



    persistent weightDone;
    persistent finalDone;



    persistent weightCapacity;
    persistent weightCounter;


    persistent weightCounterMod;
    persistent weightCounterQuo;



    persistent STATE;


    persistent resultSize;
    persistent resultSizeDivByOpW;


    persistent rtWeOut;
    persistent dwx;
    persistent dwy;









    holdOutLmtX=3;
    holdOutLmtY=3;

    numStates=7;
    wtCtrAddrW=convIndexActsBurstLengthAddrW;



    if isempty(STATE)

        rty=fi(0,0,imgAddrW,0);
        rtx=fi(0,0,imgAddrW,0);

        rtyModK=fi(0,0,unpoolKernelAddrW,0);
        rtyQuoK=fi(0,0,zKernelAddrW,0);
        rtxModK=fi(0,0,unpoolKernelAddrW,0);
        rtxQuoK=fi(0,0,zKernelAddrW,0);

        ry=fi(0,1,imgAddrW+1,0);
        rx=fi(0,1,imgAddrW+1,0);

        ryMod=fi(0,0,ceil(log2(3)),0);
        y=fi(0,1,zAddrW+1,0);
        rxMod=fi(0,0,ceil(log2(3)),0);
        x=fi(0,1,zAddrW+1,0);

        py=fi(0,0,imgAddrW,0);
        px=fi(0,0,imgAddrW,0);

        rtyMod=fi(0,0,ceil(log2(3)),0);
        rtyQuo=fi(0,0,zAddrW,0);
        rtxMod=fi(0,0,ceil(log2(3)),0);
        rtxQuo=fi(0,0,zAddrW,0);

        rtyModKMod=fi(0,0,ceil(log2(3)),0);
        rtyModKQuo=fi(0,0,unpoolKernelDivByOpWAddrW,0);
        rtxModKMod=fi(0,0,ceil(log2(3)),0);
        rtxModKQuo=fi(0,0,unpoolKernelDivByOpWAddrW,0);

        pyMod=fi(0,0,ceil(log2(3)),0);
        pyQuo=fi(0,0,zAddrW,0);
        pxMod=fi(0,0,ceil(log2(3)),0);
        pxQuo=fi(0,0,zAddrW,0);

        STATE=fi(0,0,ceil(log2(numStates)),0);
        weightDone=false;
        finalDone=false;

        weightCapacity=fi(0,0,wtCtrAddrW,0);
        weightCounter=fi(0,0,wtCtrAddrW,0);
        weightCounterMod=fi(0,0,ceil(log2(3)),0);
        weightCounterQuo=fi(0,0,wtCtrAddrW,0);

        resultSize=fi([0;0],0,imgAddrW,0);
        resultSizeDivByOpW=fi([0;0],0,zAddrW,0);

        rtWeOut=fi(zeros([3*3,1]),0,1,0);
        dwx=fi(0,0,ceil(log2(dwLimit)),0);
        dwy=fi(0,0,ceil(log2(dwLimit)),0);

    end



    doneOut=weightDone;
    [zAddr,wValid,mpwValid]=convertOpAddr(x,y,imgSize,imgSizeDivByOpW,zAddrW);
    rtzOut=rtyQuo+rtxQuo*resultSizeDivByOpW(2);
    firstWrite=rtx>=firstWritePos(1)&&rtx<firstWritePos(2)&&rty>=firstWritePos(3)&&rty<firstWritePos(4);
    finalWrite=rtx<finalWriteSize(1)&&rty<finalWriteSize(2);
    rtzSel=rtxMod+rtyMod*3;
    rSel=rxMod+ryMod*3;
    windx=weightCounter;
    rtWeOut_=rtWeOut;
    rtWeOut_(rtzSel+1)=fi(1,0,1,0)&STATE>=1&STATE<=numStates-2;
    dwx_=dwx;
    dwy_=dwy;
    r=fi(rtx*ones([3*3,1]),0,imgAddrW,0);
    c=fi(rty*ones([3*3,1]),0,imgAddrW,0);
    rtxModK_=rtxModK;
    rtyModK_=rtyModK;
    state=STATE;



    if start&&STATE==0&&(convMode==7||convMode==6)


        rty=fi(0,0,imgAddrW,0);
        rtx=fi(0,0,imgAddrW,0);

        rtyModK=fi(0,0,unpoolKernelAddrW,0);
        rtyQuoK=fi(0,0,zKernelAddrW,0);
        rtxModK=fi(0,0,unpoolKernelAddrW,0);
        rtxQuoK=fi(0,0,zKernelAddrW,0);

        ry=fi(0,1,imgAddrW+1,0);
        rx=fi(0,1,imgAddrW+1,0);

        ryMod=fi(0,0,ceil(log2(3)),0);
        y=fi(0,1,zAddrW+1,0);
        rxMod=fi(0,0,ceil(log2(3)),0);
        x=fi(0,1,zAddrW+1,0);

        py=fi(0,0,imgAddrW,0);
        px=fi(0,0,imgAddrW,0);

        rtyMod=fi(0,0,ceil(log2(3)),0);
        rtyQuo=fi(0,0,zAddrW,0);
        rtxMod=fi(0,0,ceil(log2(3)),0);
        rtxQuo=fi(0,0,zAddrW,0);

        rtyModKMod=fi(0,0,ceil(log2(3)),0);
        rtyModKQuo=fi(0,0,unpoolKernelDivByOpWAddrW,0);
        rtxModKMod=fi(0,0,ceil(log2(3)),0);
        rtxModKQuo=fi(0,0,unpoolKernelDivByOpWAddrW,0);

        pyMod=fi(0,0,ceil(log2(3)),0);
        pyQuo=fi(0,0,zAddrW,0);
        pxMod=fi(0,0,ceil(log2(3)),0);
        pxQuo=fi(0,0,zAddrW,0);

        STATE=fi(1,0,ceil(log2(numStates)),0);
        weightDone=false;
        finalDone=false;

        weightCapacity=fi(weightCounterLimit,0,wtCtrAddrW,0);
        weightCounter=fi(0,0,wtCtrAddrW,0);
        weightCounterMod=fi(0,0,ceil(log2(3)),0);
        weightCounterQuo=fi(0,0,wtCtrAddrW,0);

        resultSize=resultSizeInit;
        resultSizeDivByOpW=resultSizeDivByOpWInit;

    else
        if STATE>0

            switch STATE
            case 1

                rty=fi(rty+1,0,imgAddrW,0);
                py=fi(py+1,0,imgAddrW,0);
                rtyModK=fi(rtyModK+1,0,unpoolKernelAddrW,0);
                [rtyMod,rtyQuo]=addQ(rtyMod,rtyQuo,1,0,holdOutLmtY,0,ceil(log2(3)),0,zAddrW);
                [pyMod,pyQuo]=addQ(pyMod,pyQuo,1,0,holdOutLmtY,0,ceil(log2(3)),0,zAddrW);
                [rtyModKMod,rtyModKQuo]=addQ(rtyModKMod,rtyModKQuo,1,0,holdOutLmtY,0,ceil(log2(3)),0,unpoolKernelDivByOpWAddrW);
            case 2

                rty=fi(rty-rtyModK,0,imgAddrW,0);
                rtx=fi(rtx+1,0,imgAddrW,0);
                py=fi(py-rtyModK,0,imgAddrW,0);
                px=fi(px+1,0,imgAddrW,0);
                rtyModK=fi(0,0,unpoolKernelAddrW,0);
                rtxModK=fi(rtxModK+1,0,unpoolKernelAddrW,0);
                [rtyMod,rtyQuo]=subQ(rtyMod,rtyQuo,rtyModKMod,rtyModKQuo,holdOutLmtY,0,ceil(log2(3)),0,zAddrW);
                [rtxMod,rtxQuo]=addQ(rtxMod,rtxQuo,1,0,holdOutLmtX,0,ceil(log2(3)),0,zAddrW);
                [pyMod,pyQuo]=subQ(pyMod,pyQuo,rtyModKMod,rtyModKQuo,holdOutLmtY,0,ceil(log2(3)),0,zAddrW);
                [pxMod,pxQuo]=addQ(pxMod,pxQuo,1,0,holdOutLmtX,0,ceil(log2(3)),0,zAddrW);
                [rtyModKMod,rtyModKQuo]=resetQ(0,ceil(log2(3)),0,unpoolKernelDivByOpWAddrW);
                [rtxModKMod,rtxModKQuo]=addQ(rtxModKMod,rtxModKQuo,1,0,holdOutLmtX,0,ceil(log2(3)),0,unpoolKernelDivByOpWAddrW);
            case 3

                if weightCounter==weightCapacity-1&&inputFeatureAddr==inputFeatureAddrMax-1
                    weightDone=true;
                    weightCounter=fi(0,0,wtCtrAddrW,0);
                    [weightCounterMod,weightCounterQuo]=resetQ(0,ceil(log2(3)),0,wtCtrAddrW);
                else
                    weightCounter=fi(weightCounter+1,0,wtCtrAddrW,0);
                    [weightCounterMod,weightCounterQuo]=addQ(weightCounterMod,weightCounterQuo,1,0,holdOutLmtY,0,ceil(log2(3)),0,wtCtrAddrW);
                end
                rty=fi(rty+1,0,imgAddrW,0);
                rtx=fi(rtx-rtxModK,0,imgAddrW,0);
                if weightCounter==0
                    py=fi(0,0,imgAddrW,0);
                    px=fi(0,0,imgAddrW,0);
                else
                    py=fi(py+1,0,imgAddrW,0);
                    px=fi(px-rtxModK,0,imgAddrW,0);
                end
                rtyModK=fi(0,0,unpoolKernelAddrW,0);
                rtyQuoK=fi(rtyQuoK+1,0,zKernelAddrW,0);
                rtxModK=fi(0,0,unpoolKernelAddrW,0);
                ry=fi(ry+1,1,imgAddrW+1,0);
                [ryMod,y]=addQ(ryMod,y,1,0,holdOutLmtY,0,ceil(log2(3)),1,zAddrW+1);
                [rtyMod,rtyQuo]=addQ(rtyMod,rtyQuo,1,0,holdOutLmtY,0,ceil(log2(3)),0,zAddrW);
                [rtxMod,rtxQuo]=subQ(rtxMod,rtxQuo,rtxModKMod,rtxModKQuo,holdOutLmtX,0,ceil(log2(3)),0,zAddrW);
                if weightCounter==0
                    [pyMod,pyQuo]=resetQ(0,ceil(log2(3)),0,zAddrW);
                    [pxMod,pxQuo]=resetQ(0,ceil(log2(3)),0,zAddrW);
                else
                    [pyMod,pyQuo]=addQ(pyMod,pyQuo,1,0,holdOutLmtY,0,ceil(log2(3)),0,zAddrW);
                    [pxMod,pxQuo]=subQ(pxMod,pxQuo,rtxModKMod,rtxModKQuo,holdOutLmtX,0,ceil(log2(3)),0,zAddrW);
                end
                [rtyModKMod,rtyModKQuo]=resetQ(0,ceil(log2(3)),0,unpoolKernelDivByOpWAddrW);
                [rtxModKMod,rtxModKQuo]=resetQ(0,ceil(log2(3)),0,unpoolKernelDivByOpWAddrW);
            case 4

                if rtx==resultSize(1)-1
                    finalDone=true;
                end
                rty=fi(0,0,imgAddrW,0);
                rtx=fi(rtx+1,0,imgAddrW,0);
                py=fi(0,0,imgAddrW,0);
                px=fi(0,0,imgAddrW,0);
                rtyModK=fi(0,0,unpoolKernelAddrW,0);
                rtyQuoK=fi(0,0,zKernelAddrW,0);
                rtxModK=fi(0,0,unpoolKernelAddrW,0);
                rtxQuoK=fi(rtxQuoK+1,0,zKernelAddrW,0);
                ry=fi(0,1,imgAddrW+1,0);
                rx=fi(rx+1,1,imgAddrW+1,0);
                [ryMod,y]=resetQ(0,ceil(log2(3)),1,zAddrW+1);
                [rxMod,x]=addQ(rxMod,x,1,0,holdOutLmtX,0,ceil(log2(3)),1,zAddrW+1);
                [rtyMod,rtyQuo]=resetQ(0,ceil(log2(3)),0,zAddrW);
                [rtxMod,rtxQuo]=addQ(rtxMod,rtxQuo,1,0,holdOutLmtX,0,ceil(log2(3)),0,zAddrW);
                [pyMod,pyQuo]=resetQ(0,ceil(log2(3)),0,zAddrW);
                [pxMod,pxQuo]=resetQ(0,ceil(log2(3)),0,zAddrW);
                [rtyModKMod,rtyModKQuo]=resetQ(0,ceil(log2(3)),0,unpoolKernelDivByOpWAddrW);
                [rtxModKMod,rtxModKQuo]=resetQ(0,ceil(log2(3)),0,unpoolKernelDivByOpWAddrW);
                weightDone=true;
                weightCounter=fi(0,0,wtCtrAddrW,0);
                [weightCounterMod,weightCounterQuo]=resetQ(0,ceil(log2(3)),0,wtCtrAddrW);
            case 5

                rty=fi(rty-py,0,imgAddrW,0);
                rtx=fi(rtx-px,0,imgAddrW,0);
                py=fi(0,0,imgAddrW,0);
                px=fi(0,0,imgAddrW,0);
                rtyModK=fi(0,0,unpoolKernelAddrW,0);
                rtyQuoK=fi(rtyQuoK-weightCounter,0,zKernelAddrW,0);
                rtxModK=fi(0,0,unpoolKernelAddrW,0);
                ry=fi(ry-weightCounter,1,imgAddrW+1,0);
                [ryMod,y]=subQ(ryMod,y,weightCounterMod,weightCounterQuo,holdOutLmtY,0,ceil(log2(3)),1,zAddrW+1);
                [rtyMod,rtyQuo]=subQ(rtyMod,rtyQuo,pyMod,pyQuo,holdOutLmtY,0,ceil(log2(3)),0,zAddrW);
                [rtxMod,rtxQuo]=subQ(rtxMod,rtxQuo,pxMod,pxQuo,holdOutLmtX,0,ceil(log2(3)),0,zAddrW);
                [pyMod,pyQuo]=resetQ(0,ceil(log2(3)),0,zAddrW);
                [pxMod,pxQuo]=resetQ(0,ceil(log2(3)),0,zAddrW);
                [rtyModKMod,rtyModKQuo]=resetQ(0,ceil(log2(3)),0,unpoolKernelDivByOpWAddrW);
                [rtxModKMod,rtxModKQuo]=resetQ(0,ceil(log2(3)),0,unpoolKernelDivByOpWAddrW);
                weightDone=true;
                weightCounter=fi(0,0,wtCtrAddrW,0);
                [weightCounterMod,weightCounterQuo]=resetQ(0,ceil(log2(3)),0,wtCtrAddrW);
            case 6

                if start
                    weightDone=false;
                end
            end

            if finalDone&&inputFeatureAddr==inputFeatureAddrMax-1

                STATE=fi(0,0,ceil(log2(numStates)),0);
            else
                if weightDone==true

                    STATE=fi(6,0,ceil(log2(numStates)),0);
                else

                    if rtyModK<kernelSize(2)-1&&rty~=resultSize(2)-1
                        STATE=fi(1,0,ceil(log2(numStates)),0);
                    else
                        if rtxModK<kernelSize(1)-1&&rtx~=resultSize(1)-1
                            STATE=fi(2,0,ceil(log2(numStates)),0);
                        else
                            if rty~=resultSize(2)-1
                                if weightCounter==weightCapacity-1&&inputFeatureAddr~=inputFeatureAddrMax-1
                                    STATE=fi(5,0,ceil(log2(numStates)),0);
                                else
                                    STATE=fi(3,0,ceil(log2(numStates)),0);
                                end
                            else
                                if inputFeatureAddr~=inputFeatureAddrMax-1
                                    STATE=fi(5,0,ceil(log2(numStates)),0);
                                else
                                    STATE=fi(4,0,ceil(log2(numStates)),0);
                                end
                            end
                        end
                    end
                end
            end

        end
    end
end

function[cMod,cQuo]=addQ(aMod,aQuo,bMod,bQuo,holdOutLmt,sMod,wMod,sQuo,wQuo)



    cQuo=fi(aQuo+bQuo,sQuo,wQuo,0);
    tmp=aMod+bMod;
    if tmp>=holdOutLmt
        cQuo=fi(cQuo+1,sQuo,wQuo,0);
        cMod=fi(tmp-holdOutLmt,sMod,wMod,0);
    else
        cMod=fi(tmp,sMod,wMod,0);
    end
end

function[cMod,cQuo]=subQ(aMod,aQuo,bMod,bQuo,holdOutLmt,sMod,wMod,sQuo,wQuo)



    cQuo=fi(aQuo-bQuo,sQuo,wQuo,0);
    if aMod<bMod
        cQuo=fi(cQuo-1,sQuo,wQuo,0);
        cMod=fi(aMod+holdOutLmt-bMod,sMod,wMod,0);
    else
        cMod=fi(aMod-bMod,sMod,wMod,0);
    end
end

function[cMod,cQuo]=resetQ(sMod,wMod,sQuo,wQuo)

    cQuo=fi(0,sQuo,wQuo,0);
    cMod=fi(0,sMod,wMod,0);
end

function[zAddr,wValid,mpwValid]=convertOpAddr(x,y,imgSize,imgSizeDivByOpW,zAddrW)

    z=y+x*imgSizeDivByOpW(2);
    rx=x*3+[0,1,2,0,1,2,0,1,2];
    ry=y*3+[0,0,0,1,1,1,2,2,2];
    w=(rx>=0&rx<imgSize(1))&(ry>=0&ry<imgSize(2));

    zAddr=fi(z*ones([3*3,1]),1,zAddrW*2+1,0);
    wValid=fi(w,0,1,0);
    mpwValid=fi(false([1,3*3]),0,1,0);
end
