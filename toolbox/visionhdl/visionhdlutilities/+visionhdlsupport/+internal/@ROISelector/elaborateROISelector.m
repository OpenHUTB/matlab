function topNet=elaborateROISelector(this,topNet,blockInfo,inSig,outSig)







    dataIn=inSig(1);
    inRate=dataIn.SimulinkRate;
    hstartIn=inSig(2);
    hendIn=inSig(3);
    vstartIn=inSig(4);
    vendIn=inSig(5);
    validIn=inSig(6);

    for ii=1:(blockInfo.NumberOfRegions*6)
        sig=outSig(ii);
        sig.SimulinkRate=inRate;
    end


    dataInType=dataIn.Type;
    countWS=16;
    uCountType=pir_ufixpt_t(countWS,0);

    zeroconst=newDataSignal(topNet,'zeroconst',dataInType,inRate);
    pirelab.getConstComp(topNet,zeroconst,0,'zeroconst');

    minusone=newDataSignal(topNet,'minusone',uCountType,inRate);
    pirelab.getConstComp(topNet,minusone,(2^countWS)-1,'minusoneconst');

    oneconst=newDataSignal(topNet,'oneconst',uCountType,inRate);
    pirelab.getConstComp(topNet,oneconst,1,'oneconstcomp');


    dataInReg=newDataSignal(topNet,'dataInReg',dataInType,inRate);
    dataInDlyReg=newDataSignal(topNet,'dataInDlyReg',dataInType,inRate);
    hStartInReg=newControlSignal(topNet,'hStartInReg',inRate);
    hEndInReg=newControlSignal(topNet,'hEndInReg',inRate);
    vStartInReg=newControlSignal(topNet,'vStartInReg',inRate);
    vEndInReg=newControlSignal(topNet,'vEndInReg',inRate);
    validInReg=newControlSignal(topNet,'validInReg',inRate);

    vEndInRegDelay=newControlSignal(topNet,'vEndInRegDelay',inRate);

    pirelab.getUnitDelayComp(topNet,dataIn,dataInReg,'dataIReg',0);
    pirelab.getUnitDelayComp(topNet,dataInReg,dataInDlyReg,'dataIDlyReg',0);
    pirelab.getUnitDelayComp(topNet,hstartIn,hStartInReg,'hSIReg',0);
    pirelab.getUnitDelayComp(topNet,hendIn,hEndInReg,'hEIReg',0);
    pirelab.getUnitDelayComp(topNet,vstartIn,vStartInReg,'vSIReg',0);
    pirelab.getUnitDelayComp(topNet,vendIn,vEndInReg,'vEIReg',0);
    pirelab.getUnitDelayComp(topNet,validIn,validInReg,'valIReg',0);

    pirelab.getUnitDelayComp(topNet,vEndInReg,vEndInRegDelay,'vEIRegD',0);

    hEndInRegDelay=newControlSignal(topNet,'hEndInRegDelay',inRate);
    pirelab.getUnitDelayComp(topNet,hEndInReg,hEndInRegDelay,'hEIDReg',0);

    inFrame=newControlSignal(topNet,'inFrame',inRate);
    inLine=newControlSignal(topNet,'inLine',inRate);

    inFramePrev=newControlSignal(topNet,'inFramePrev',inRate);
    inLinePrev=newControlSignal(topNet,'inLinePrev',inRate);

    inFrameNext=newControlSignal(topNet,'inFrameNext',inRate);
    inFrameTerm1=newControlSignal(topNet,'inFrame1Term',inRate);
    inFrameTerm2=newControlSignal(topNet,'inFrame2Term',inRate);
    inFrameTerm3=newControlSignal(topNet,'inFrame3Term',inRate);

    inLineNext=newControlSignal(topNet,'inLineNext',inRate);
    inLineTerm1=newControlSignal(topNet,'inLine1Term',inRate);
    inLineTerm2=newControlSignal(topNet,'inLine2Term',inRate);
    inLineTerm3=newControlSignal(topNet,'inLine3Term',inRate);
    inLineTerm4=newControlSignal(topNet,'inLine4Term',inRate);
    inLineTerm5=newControlSignal(topNet,'inLine5Term',inRate);
    inLineTerm6=newControlSignal(topNet,'inLine6Term',inRate);

    vEndInv=newControlSignal(topNet,'vEndInv',inRate);
    pirelab.getBitwiseOpComp(topNet,vEndInReg,vEndInv,'NOT');

    hEndInv=newControlSignal(topNet,'hEndInv',inRate);
    pirelab.getBitwiseOpComp(topNet,hEndInReg,hEndInv,'NOT');

    validInv=newControlSignal(topNet,'ValidInv',inRate);
    pirelab.getBitwiseOpComp(topNet,validInReg,validInv,'NOT');

    inFrameInv=newControlSignal(topNet,'inFrameInv',inRate);
    pirelab.getBitwiseOpComp(topNet,inFrame,inFrameInv,'NOT');

    inLineInv=newControlSignal(topNet,'inLineInv',inRate);
    pirelab.getBitwiseOpComp(topNet,inLine,inLineInv,'NOT');

    pirelab.getUnitDelayComp(topNet,inFrameNext,inFrame,'inFReg',0);
    pirelab.getUnitDelayComp(topNet,inLineNext,inLine,'inLReg',0);

    pirelab.getBitwiseOpComp(topNet,[inFrameTerm1,...
    inFrameTerm2,...
    inFrameTerm3],...
    inFrameNext,'OR');
    pirelab.getBitwiseOpComp(topNet,[inLineTerm1,...
    inLineTerm2,...
    inLineTerm3,...
    inLineTerm4,...
    inLineTerm5,...
    inLineTerm6],...
    inLineNext,'OR');

    pirelab.getBitwiseOpComp(topNet,[vEndInv,inFrame],inFrameTerm1,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInReg,vStartInReg],inFrameTerm2,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInv,inFrame],inFrameTerm3,'AND');

    pirelab.getBitwiseOpComp(topNet,[hEndInv,inLine],inLineTerm1,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInReg,hStartInReg,vStartInReg],inLineTerm2,'AND');
    pirelab.getBitwiseOpComp(topNet,[vStartInReg,inLine],inLineTerm3,'AND');
    pirelab.getBitwiseOpComp(topNet,[inFrameInv,inLine],inLineTerm4,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInv,inLine],inLineTerm5,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInReg,hStartInReg,vEndInv,inFrame,inLineInv],inLineTerm6,'AND');




    hCount=newDataSignal(topNet,'hCount',uCountType,inRate);
    vCount=newDataSignal(topNet,'vCount',uCountType,inRate);

    hCountInit=newControlSignal(topNet,'hCountInit',inRate);
    hEn=newControlSignal(topNet,'hEn',inRate);
    vCountInit=newControlSignal(topNet,'vCountInit',inRate);
    vEn=newControlSignal(topNet,'vEn',inRate);

    if blockInfo.VerticalReuse

        vCountReset1=newControlSignal(topNet,'vCountReset1',inRate);
        vCountReset2=newControlSignal(topNet,'vCountReset2',inRate);

        vIndexWS=ceil(log2(blockInfo.NumVTiles+1));
        vIndexType=pir_ufixpt_t(vIndexWS,0);
        vIndex=newDataSignal(topNet,'vIndex',vIndexType,inRate);


        vEndInRegDelay3=newControlSignal(topNet,'vEndInRegDelay3',inRate);
        pirelab.getIntDelayComp(topNet,vEndInReg,vEndInRegDelay3,3,'hEndInRegDelay3',0);
        vEnIndex=newControlSignal(topNet,'vEnIndex',inRate);
        pirelab.getBitwiseOpComp(topNet,[vStartInReg,vCountReset1],vEnIndex,'OR');
        pirelab.getCounterComp(topNet,[vEndInRegDelay3,vEnIndex],vIndex,...
        'Count limited',...
        0.0,...
        1.0,...
        2^vIndexWS-1,...
        true,...
        false,...
        true,...
        false,...
        'vIndexCounter');

        bpType=fi(0,0,vIndexWS,0);
        tableidx={fi((0:2^vIndexWS-1),bpType.numerictype)};
        oType=fi(0,0,16,0);
        fType=fi(0,0,32,31);

        if blockInfo.uniformvTop==false


            tabledatavTop=blockInfo.TableDatavTop;
            lutOutvTop=newDataSignal(topNet,'lutOutvTop',uCountType,inRate);

            regcomp=pirelab.getLookupNDComp(topNet,vIndex,lutOutvTop,...
            tabledatavTop,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
            regcomp.addComment('Lookup Table')
        end

        tabledatavBottom=blockInfo.TableDatavBottom;
        lutOutvBottom=newDataSignal(topNet,'lutOutvBottom',uCountType,inRate);

        regcomp=pirelab.getLookupNDComp(topNet,vIndex,lutOutvBottom,...
        tabledatavBottom,0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
        regcomp.addComment('Lookup Table')

        plusone=newDataSignal(topNet,'plusone',uCountType,inRate);
        pirelab.getConstComp(topNet,plusone,1,'plusoneconst');
        lutOutvBottomPlus=newDataSignal(topNet,'lutOutvBottomPlus',uCountType,inRate);
        pirelab.getAddComp(topNet,[lutOutvBottom,plusone],lutOutvBottomPlus,'Floor','Wrap');

        vCountComp=newControlSignal(topNet,'vCountComp',inRate);
        pirelab.getRelOpComp(topNet,[vCount,lutOutvBottomPlus],vCountComp,'==');

        pirelab.getBitwiseOpComp(topNet,[vCountComp,validInReg,hStartInReg],vCountReset1,'AND');

        pirelab.getBitwiseOpComp(topNet,[inFrameNext,validInReg,vStartInReg],vCountReset2,'AND');

        pirelab.getBitwiseOpComp(topNet,[inFrameNext,validInReg,hStartInReg],hCountInit,'AND');
        pirelab.getBitwiseOpComp(topNet,[inFrameNext,inLineNext,validInReg],hEn,'AND');

        pirelab.getBitwiseOpComp(topNet,[vCountReset1,vCountReset2],vCountInit,'OR');
        pirelab.getBitwiseOpComp(topNet,[inFrameNext,inLine,validInReg,hEndInReg],vEn,'AND');
    else
        pirelab.getBitwiseOpComp(topNet,[inFrameNext,validInReg,hStartInReg],hCountInit,'AND');
        pirelab.getBitwiseOpComp(topNet,[inFrameNext,inLineNext,validInReg],hEn,'AND');

        pirelab.getBitwiseOpComp(topNet,[inFrameNext,validInReg,vStartInReg],vCountInit,'AND');
        pirelab.getBitwiseOpComp(topNet,[inFrameNext,inLine,validInReg,hEndInReg],vEn,'AND');
    end

    pirelab.getCounterComp(topNet,[hCountInit,hEn],hCount,...
    'Count limited',...
    1.0,...
    1.0,...
    2^countWS-1,...
    true,...
    false,...
    true,...
    false,...
    'hCounter');

    pirelab.getCounterComp(topNet,[vCountInit,vEn],vCount,...
    'Count limited',...
    1.0,...
    1.0,...
    2^countWS-1,...
    true,...
    false,...
    true,...
    false,...
    'vCounter');


    for ii=1:blockInfo.NumberOfRegions

        hLeft(ii)=newDataSignal(topNet,sprintf('hLeft%d',ii),uCountType,inRate);%#ok
        hRight(ii)=newDataSignal(topNet,sprintf('hRight%d',ii),uCountType,inRate);%#ok
        vTop(ii)=newDataSignal(topNet,sprintf('vTop%d',ii),uCountType,inRate);%#ok
        vBottom(ii)=newDataSignal(topNet,sprintf('vBottom%d',ii),uCountType,inRate);%#ok
        vBottomPlus(ii)=newDataSignal(topNet,sprintf('vBottomPlus%d',ii),uCountType,inRate);%#ok

        if blockInfo.RegionsSource==1

            portSig=inSig(ii+6);
            portDT=portSig.Type.BaseType;

            splitComp=split(portSig);
            portVectSigs=splitComp.PirOutputSignals;
            XPosSig=portVectSigs(1);
            YPosSig=portVectSigs(2);
            XSizeSig=portVectSigs(3);
            YSizeSig=portVectSigs(4);

            if portDT~=uCountType
                convXPos=newDataSignal(topNet,sprintf('conv%dXPos',ii),uCountType,inRate);
                convYPos=newDataSignal(topNet,sprintf('conv%dYPos',ii),uCountType,inRate);
                convXSize=newDataSignal(topNet,sprintf('conv%dXSize',ii),uCountType,inRate);
                convYSize=newDataSignal(topNet,sprintf('conv%dYSize',ii),uCountType,inRate);

                pirelab.getDTCComp(topNet,XPosSig,convXPos);
                pirelab.getDTCComp(topNet,YPosSig,convYPos);
                pirelab.getDTCComp(topNet,XSizeSig,convXSize);
                pirelab.getDTCComp(topNet,YSizeSig,convYSize);

                XPosSig=convXPos;
                YPosSig=convYPos;
                XSizeSig=convXSize;
                YSizeSig=convYSize;
            end



            if dataInType.isArrayType
                if dataIn.Type.Dimensions~=1
                    scaleXPos=newDataSignal(topNet,sprintf('scale%dXPos',ii),uCountType,inRate);
                    scaleXPosAdd=newDataSignal(topNet,sprintf('scale%dXPosAdd',ii),uCountType,inRate);
                    shiftLength=log2(single(dataIn.Type.Dimensions));
                    pirelab.getBitShiftComp(topNet,XPosSig,scaleXPos,'srl',shiftLength);
                    pirelab.getAddComp(topNet,[scaleXPos,oneconst],scaleXPosAdd,'Floor','Wrap');
                    scaleXSizeSig=newDataSignal(topNet,sprintf('scale%dXPos',ii),uCountType,inRate);
                    pirelab.getBitShiftComp(topNet,XSizeSig,scaleXSizeSig,'srl',shiftLength);
                    XPosSig=scaleXPosAdd;
                    XSizeSig=scaleXSizeSig;
                end
            end


            hTempAdd=newDataSignal(topNet,sprintf('hTemp%dAdd',ii),uCountType,inRate);
            vTempAdd=newDataSignal(topNet,sprintf('vTemp%dAdd',ii),uCountType,inRate);

            hRightAdd=newDataSignal(topNet,sprintf('hRight%dAdd',ii),uCountType,inRate);
            vBottomAdd=newDataSignal(topNet,sprintf('vBottom%dAdd',ii),uCountType,inRate);

            pirelab.getAddComp(topNet,[XPosSig,XSizeSig],hTempAdd,'Floor','Wrap');
            pirelab.getAddComp(topNet,[YPosSig,YSizeSig],vTempAdd,'Floor','Wrap');

            pirelab.getAddComp(topNet,[hTempAdd,minusone],hRightAdd,'Floor','Wrap');
            pirelab.getAddComp(topNet,[vTempAdd,minusone],vBottomAdd,'Floor','Wrap');

            pirelab.getUnitDelayEnabledComp(topNet,XPosSig,hLeft(ii),vstartIn,sprintf('left%dreg',ii),0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,hRightAdd,hRight(ii),vstartIn,sprintf('right%dreg',ii),0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,YPosSig,vTop(ii),vstartIn,sprintf('top%dreg',ii),0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,vBottomAdd,vBottom(ii),vstartIn,sprintf('bottom%dreg',ii),0.0,'',false);
            pirelab.getUnitDelayEnabledComp(topNet,vTempAdd,vBottomPlus(ii),vstartIn,sprintf('bottomplus%dreg',ii),0.0,'',false);
        else



            if dataInType.isArrayType
                left=max(1,(floor(blockInfo.Regions(ii,1)/dataIn.Type.Dimensions(1))+1));
                right=left+(blockInfo.Regions(ii,3)/dataIn.Type.Dimensions(1))-1;
                top=blockInfo.Regions(ii,2);
                bottom=blockInfo.Regions(ii,2)+blockInfo.Regions(ii,4)-1;
            else
                left=blockInfo.Regions(ii,1);
                right=blockInfo.Regions(ii,1)+blockInfo.Regions(ii,3)-1;
                top=blockInfo.Regions(ii,2);
                bottom=blockInfo.Regions(ii,2)+blockInfo.Regions(ii,4)-1;
            end
            pirelab.getConstComp(topNet,hLeft(ii),left,'hLeftConst');
            pirelab.getConstComp(topNet,hRight(ii),right,'hRightConst');
            if blockInfo.VerticalReuse==false

                pirelab.getConstComp(topNet,vTop(ii),top,'vTopConst');
                pirelab.getConstComp(topNet,vBottom(ii),bottom,'vBottomConst');
                pirelab.getConstComp(topNet,vBottomPlus(ii),bottom+1,'vBottomPlusConst');
            end
        end

        validDelay(ii)=newControlSignal(topNet,sprintf('validDelay%dROI',ii),inRate);%#ok
        hendDelay(ii)=newControlSignal(topNet,sprintf('hendDelay%dROI',ii),inRate);%#ok
        hendDelayInv(ii)=newControlSignal(topNet,sprintf('hendDelayInv%dROI',ii),inRate);%#ok

        hCompStartROI(ii)=newControlSignal(topNet,sprintf('hCompStart%dROI',ii),inRate);%#ok
        hCompEndROI(ii)=newControlSignal(topNet,sprintf('hCompEnd%dROI',ii),inRate);%#ok
        hCompGreaterStartROI(ii)=newControlSignal(topNet,sprintf('hCompGreaterStart%dROI',ii),inRate);%#ok
        hCompLessThanEndROI(ii)=newControlSignal(topNet,sprintf('hCompLessThanEnd%dROI',ii),inRate);%#ok

        pirelab.getRelOpComp(topNet,[hCount,hLeft(ii)],hCompStartROI(ii),'==');
        pirelab.getRelOpComp(topNet,[hCount,hRight(ii)],hCompEndROI(ii),'==');
        pirelab.getRelOpComp(topNet,[hCount,hLeft(ii)],hCompGreaterStartROI(ii),'>=');
        pirelab.getRelOpComp(topNet,[hCount,hRight(ii)],hCompLessThanEndROI(ii),'<=');

        vCompStartROI(ii)=newControlSignal(topNet,sprintf('vCompStart%dROI',ii),inRate);%#ok
        vCompEndROI(ii)=newControlSignal(topNet,sprintf('vCompEnd%dROI',ii),inRate);%#ok
        vCompEndPlusROI(ii)=newControlSignal(topNet,sprintf('vCompEndPlus%dROI',ii),inRate);%#ok
        vCompGreaterStartROI(ii)=newControlSignal(topNet,sprintf('vCompGreaterStart%dROI',ii),inRate);%#ok
        vCompLessThanEndROI(ii)=newControlSignal(topNet,sprintf('vCompLessThanEnd%dROI',ii),inRate);%#ok
        vCompLessThanEndPlusROI(ii)=newControlSignal(topNet,sprintf('vCompLessThanEndPlus%dROI',ii),inRate);%#ok

        if blockInfo.VerticalReuse
            if blockInfo.uniformvTop==false

                pirelab.getRelOpComp(topNet,[vCount,lutOutvTop],vCompStartROI(ii),'==',false,'vCompStartROI');
                pirelab.getRelOpComp(topNet,[vCount,lutOutvTop],vCompGreaterStartROI(ii),'>=');
            else

                pirelab.getConstComp(topNet,vTop(ii),top,'vTopConst');
                pirelab.getRelOpComp(topNet,[vCount,vTop(ii)],vCompStartROI(ii),'==');
                pirelab.getRelOpComp(topNet,[vCount,vTop(ii)],vCompGreaterStartROI(ii),'>=');
            end

            pirelab.getRelOpComp(topNet,[vCount,lutOutvBottom],vCompEndROI(ii),'==');
            pirelab.getRelOpComp(topNet,[vCount,lutOutvBottom],vCompLessThanEndROI(ii),'<=');

            pirelab.getRelOpComp(topNet,[vCount,lutOutvBottomPlus],vCompLessThanEndPlusROI(ii),'<=');
            pirelab.getRelOpComp(topNet,[vCount,lutOutvBottomPlus],vCompEndPlusROI(ii),'==');

        else
            pirelab.getRelOpComp(topNet,[vCount,vTop(ii)],vCompStartROI(ii),'==');
            pirelab.getRelOpComp(topNet,[vCount,vBottom(ii)],vCompEndROI(ii),'==');
            pirelab.getRelOpComp(topNet,[vCount,vTop(ii)],vCompGreaterStartROI(ii),'>=');
            pirelab.getRelOpComp(topNet,[vCount,vBottom(ii)],vCompLessThanEndROI(ii),'<=');

            pirelab.getRelOpComp(topNet,[vCount,vBottomPlus(ii)],vCompLessThanEndPlusROI(ii),'<=');
            pirelab.getRelOpComp(topNet,[vCount,vBottomPlus(ii)],vCompEndPlusROI(ii),'==');
        end

        prehStart(ii)=newControlSignal(topNet,sprintf('prehStart%dROI',ii),inRate);%#ok
        prehEnd(ii)=newControlSignal(topNet,sprintf('prehEnd%dROI',ii),inRate);%#ok
        prehEndEdge(ii)=newControlSignal(topNet,sprintf('prehEndEdge%dROI',ii),inRate);%#ok
        prevStart(ii)=newControlSignal(topNet,sprintf('prevStart%dROI',ii),inRate);%#ok
        prevEnd(ii)=newControlSignal(topNet,sprintf('prevEnd%dROI',ii),inRate);%#ok
        preNormvEnd(ii)=newControlSignal(topNet,sprintf('preNormvEnd%dROI',ii),inRate);%#ok
        preEdge1vEnd(ii)=newControlSignal(topNet,sprintf('preEdge1vEnd%dROI',ii),inRate);%#ok
        preEdge2vEnd(ii)=newControlSignal(topNet,sprintf('preEdge2vEnd%dROI',ii),inRate);%#ok
        preEdge3vEnd(ii)=newControlSignal(topNet,sprintf('preEdge3vEnd%dROI',ii),inRate);%#ok
        preValid(ii)=newControlSignal(topNet,sprintf('prevalid%dROI',ii),inRate);%#ok
        preValidEdge(ii)=newControlSignal(topNet,sprintf('prevalidedge%dROI',ii),inRate);%#ok

        preLastEdge(ii)=newControlSignal(topNet,sprintf('prelastedge%dROI',ii),inRate);%#ok

        hSOR(ii)=newControlSignal(topNet,sprintf('hSOR%dROI',ii),inRate);%#ok
        hEOR(ii)=newControlSignal(topNet,sprintf('hEOR%dROI',ii),inRate);%#ok
        vSOR(ii)=newControlSignal(topNet,sprintf('vSOR%dROI',ii),inRate);%#ok
        vEOR(ii)=newControlSignal(topNet,sprintf('vEOR%dROI',ii),inRate);%#ok

        vEORDelay(ii)=newControlSignal(topNet,sprintf('vEORDelay%dROI',ii),inRate);%#ok

        pirelab.getBitwiseOpComp(topNet,[hStartInReg,hCompStartROI(ii)],hSOR(ii),'OR');
        pirelab.getBitwiseOpComp(topNet,[vStartInReg,vCompStartROI(ii)],vSOR(ii),'OR');

        pirelab.getBitwiseOpComp(topNet,[preValid(ii),hCompEndROI(ii)],hEOR(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[preValid(ii),vCompEndROI(ii)],vEOR(ii),'AND');

        pirelab.getBitwiseOpComp(topNet,[hCompGreaterStartROI(ii),...
        hCompLessThanEndROI(ii),...
        vCompGreaterStartROI(ii),...
        vCompLessThanEndROI(ii),...
        inFrame,...
        inLine,...
        validInReg],...
        preValid(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[hCompGreaterStartROI(ii),...
        hCompLessThanEndROI(ii),...
        vCompGreaterStartROI(ii),...
        vCompLessThanEndPlusROI(ii),...
        inFramePrev,...
        inLinePrev,...
        validDelay(ii)],...
        preValidEdge(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[vCompGreaterStartROI(ii),...
        vCompLessThanEndPlusROI(ii),...
        vEndInReg],...
        preLastEdge(ii),'AND');

        pirelab.getBitwiseOpComp(topNet,[preValid(ii),hSOR(ii)],prehStart(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[preValid(ii),hSOR(ii),vSOR(ii)],prevStart(ii),'AND');

        pirelab.getBitwiseOpComp(topNet,[preValidEdge(ii),validDelay(ii),hEndInRegDelay,hendDelayInv(ii)],prehEndEdge(ii),'AND');

        pirelab.getBitwiseOpComp(topNet,[prehEndEdge(ii),hEOR(ii)],prehEnd(ii),'OR');

        pirelab.getUnitDelayComp(topNet,vEOR(ii),vEORDelay(ii),'vEORPrevReg',0);

        pirelab.getBitwiseOpComp(topNet,[validDelay(ii),preValidEdge(ii),vEndInRegDelay],preEdge1vEnd(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[validDelay(ii),preValidEdge(ii),hEndInReg,vCompEndPlusROI(ii)],preEdge2vEnd(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[validDelay(ii),prehEnd(ii),vEORDelay(ii)],preEdge3vEnd(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[preValid(ii),hEOR(ii),vEOR(ii)],preNormvEnd(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[preEdge1vEnd(ii),preEdge2vEnd(ii),preEdge3vEnd(ii),preNormvEnd(ii)],prevEnd(ii),'OR');


        finalpreValid(ii)=newControlSignal(topNet,sprintf('finalpreValid%dROI',ii),inRate);%#ok
        pirelab.getBitwiseOpComp(topNet,[preValid(ii),prehEnd(ii),prevEnd(ii)],finalpreValid(ii),'OR');

        preDataMux(ii)=newDataSignal(topNet,'predataMux',dataInType,inRate);%#ok
        pirelab.getSwitchComp(topNet,[zeroconst,dataInDlyReg],preDataMux(ii),finalpreValid(ii),'gatemux');

        pirelab.getUnitDelayComp(topNet,finalpreValid(ii),validDelay(ii),'validDelayReg',0);
        pirelab.getUnitDelayComp(topNet,inFrame,inFramePrev,'inFramePrevReg',0);
        pirelab.getUnitDelayComp(topNet,inLine,inLinePrev,'inLinePrevReg',0);

        pirelab.getUnitDelayComp(topNet,prehEnd(ii),hendDelay(ii),'hEndPrevReg',0);
        pirelab.getBitwiseOpComp(topNet,hendDelay(ii),hendDelayInv(ii),'NOT');


        vStartBuf(ii)=newControlSignal(topNet,sprintf('vStartBuf%dROI',ii),inRate);%#ok
        vStartBufTerm1(ii)=newControlSignal(topNet,sprintf('vStartBufTerm1%dROI',ii),inRate);%#ok
        vStartBufTerm2(ii)=newControlSignal(topNet,sprintf('vStartBufTerm2%dROI',ii),inRate);%#ok


        finalprevEnd(ii)=newControlSignal(topNet,sprintf('finalprevEnd%dROI',ii),inRate);%#ok
        finalprevEndReg(ii)=newControlSignal(topNet,sprintf('finalprevEndReg%dROI',ii),inRate);%#ok
        finalprevEndInv(ii)=newControlSignal(topNet,sprintf('finalprevEndInv%dROI',ii),inRate);%#ok
        preLastEdgeReg(ii)=newControlSignal(topNet,sprintf('prelastedgeReg%dROI',ii),inRate);%#ok
        prevEndTerm(ii)=newControlSignal(topNet,sprintf('finalprevEnd%dROI',ii),inRate);%#ok


        pirelab.getBitwiseOpComp(topNet,[prevStart(ii),vStartBufTerm1(ii)],vStartBufTerm2(ii),'OR');
        pirelab.getBitwiseOpComp(topNet,[finalprevEndInv(ii),vStartBuf(ii)],vStartBufTerm1(ii),'AND');

        pirelab.getUnitDelayComp(topNet,vStartBufTerm2(ii),vStartBuf(ii),'vSBufReg',0);
        pirelab.getUnitDelayComp(topNet,preLastEdge(ii),preLastEdgeReg(ii),'lastEdgeReg',0);


        pirelab.getBitwiseOpComp(topNet,[vStartBuf(ii),preLastEdgeReg(ii)],prevEndTerm(ii),'AND');
        pirelab.getBitwiseOpComp(topNet,[prevEndTerm(ii),prevEnd(ii)],finalprevEnd(ii),'OR');

        pirelab.getUnitDelayComp(topNet,finalprevEnd(ii),finalprevEndReg(ii),'finalvEdgeReg',0);
        pirelab.getBitwiseOpComp(topNet,finalprevEndReg(ii),finalprevEndInv(ii),'NOT');



        outIdx=(ii-1)*6+1;
        pirelab.getUnitDelayComp(topNet,preDataMux(ii),outSig(outIdx),'outDReg',0);
        pirelab.getUnitDelayComp(topNet,prehStart(ii),outSig(outIdx+1),'outHSReg',0);
        pirelab.getUnitDelayComp(topNet,prevStart(ii),outSig(outIdx+3),'outVSReg',0);
        pirelab.getUnitDelayComp(topNet,finalprevEnd(ii),outSig(outIdx+4),'outVEReg',0);





        pirelab.getWireComp(topNet,hendDelay(ii),outSig(outIdx+2),'outHEReg');
        pirelab.getWireComp(topNet,validDelay(ii),outSig(outIdx+5),'outVEReg');

    end

end



function signal=newControlSignal(topNet,name,rate)
    controlType=pir_ufixpt_t(1,0);
    signal=topNet.addSignal(controlType,name);
    signal.SimulinkRate=rate;
end

function signal=newDataSignal(topNet,name,inType,rate)
    signal=topNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end
