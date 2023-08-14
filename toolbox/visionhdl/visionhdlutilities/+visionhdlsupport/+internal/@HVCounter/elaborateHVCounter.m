function topNet=elaborateHVCounter(this,topNet,blockInfo,inSig,outSig)








    hstartIn=inSig(1);
    hendIn=inSig(2);
    vstartIn=inSig(3);
    vendIn=inSig(4);
    validIn=inSig(5);


    hCount=outSig(1);
    vCount=outSig(2);
    hstartOut=outSig(3);
    hendOut=outSig(4);
    vstartOut=outSig(5);
    vendOut=outSig(6);
    validOut=outSig(7);


    inRate=hstartIn.SimulinkRate;
    for ii=1:numel(outSig)
        sig=outSig(ii);
        sig.SimulinkRate=inRate;
    end



    hCountSize=ceil(log2(1+double(blockInfo.ActivePixelsPerLine)));
    vCountSize=ceil(log2(1+double(blockInfo.ActiveVideoLines)));




    hFi=fi(0,0,hCountSize,0);
    vFi=fi(0,0,vCountSize,0);




    hStartInReg=newControlSignal(topNet,'HStartInReg',inRate);
    hEndInReg=newControlSignal(topNet,'HEndInReg',inRate);
    vStartInReg=newControlSignal(topNet,'VStartInReg',inRate);
    vEndInReg=newControlSignal(topNet,'VEndInReg',inRate);
    validInReg=newControlSignal(topNet,'ValidInReg',inRate);

    pirelab.getUnitDelayComp(topNet,hstartIn,hStartInReg,'hSIReg',0);
    pirelab.getUnitDelayComp(topNet,hendIn,hEndInReg,'hEIReg',0);
    pirelab.getUnitDelayComp(topNet,vstartIn,vStartInReg,'vSIReg',0);
    pirelab.getUnitDelayComp(topNet,vendIn,vEndInReg,'vEIReg',0);
    pirelab.getUnitDelayComp(topNet,validIn,validInReg,'valIReg',0);


    hStartOutReg=newControlSignal(topNet,'HStartOutReg',inRate);
    hEndOutReg=newControlSignal(topNet,'HEndOutReg',inRate);
    vStartOutReg=newControlSignal(topNet,'VStartOutReg',inRate);
    vEndOutReg=newControlSignal(topNet,'VEndOutReg',inRate);
    validOutReg=newControlSignal(topNet,'ValidOutReg',inRate);
    muxCtrl=newControlSignal(topNet,'muxCtrl',inRate);

    notVEndOutReg=newControlSignal(topNet,'notVEndOutReg',inRate);



    pirelab.getUnitDelayComp(topNet,hStartOutReg,hstartOut,'refhSOReg',0);
    pirelab.getUnitDelayComp(topNet,hEndOutReg,hendOut,'refhEOReg',0);
    pirelab.getUnitDelayComp(topNet,vStartOutReg,vstartOut,'refvSOReg',0);
    pirelab.getUnitDelayComp(topNet,vEndOutReg,vendOut,'refvEOReg',0);
    pirelab.getUnitDelayComp(topNet,validOutReg,validOut,'refvalOReg',0);
    pirelab.getUnitDelayComp(topNet,validOutReg,muxCtrl,'muxReg',0);


    hCountCounter=newSignalLike(topNet,'hCountCounter',hCount);
    vCountCounter=newSignalLike(topNet,'vCountCounter',vCount);

    hZero=newSignalLike(topNet,'hZero',hCount);
    vZero=newSignalLike(topNet,'vZero',vCount);
    pirelab.getConstComp(topNet,hZero,0);
    pirelab.getConstComp(topNet,vZero,0);



    validInRegDly=newControlSignal(topNet,'validInRegDly',inRate);
    pirelab.getUnitDelayComp(topNet,validInReg,validInRegDly,'valIRegDly',0);

    hCountEn=newControlSignal(topNet,'HCountEn',inRate);
    vCountEn=newControlSignal(topNet,'VCountEn',inRate);
    vCountPre=newControlSignal(topNet,'VCountPre',inRate);
    hCountFrame=newControlSignal(topNet,'HCountFrame',inRate);
    hCountLine=newControlSignal(topNet,'HCountLine',inRate);


    hCountNotMax=newControlSignal(topNet,'HCountNotMax',inRate);
    vCountNotMax=newControlSignal(topNet,'VCountNotMax',inRate);

    pirelab.getCompareToValueComp(topNet,hCountCounter,hCountNotMax,'~=',realmax(hFi));
    pirelab.getCompareToValueComp(topNet,vCountCounter,vCountNotMax,'~=',realmax(vFi));

    [hvInFrame,hvInLine,vCountRst,hCountRst,hvInFrameNext,hvInLineNext]=...
    lineframeFSM(topNet,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg,inRate,'hv');

    pirelab.getBitwiseOpComp(topNet,[hStartInReg],hStartOutReg,'AND');
    pirelab.getBitwiseOpComp(topNet,[hEndInReg],hEndOutReg,'AND');
    pirelab.getBitwiseOpComp(topNet,[vStartInReg],vStartOutReg,'AND');
    pirelab.getBitwiseOpComp(topNet,[vEndInReg],vEndOutReg,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInReg],validOutReg,'AND');

    pirelab.getBitwiseOpComp(topNet,[hvInFrameNext,hvInFrame],hCountFrame,'OR');
    pirelab.getBitwiseOpComp(topNet,[hvInLineNext,hvInLine],hCountLine,'OR');

    pirelab.getBitwiseOpComp(topNet,[validInReg,hCountFrame,hCountLine,hCountNotMax],hCountEn,'AND');

    pirelab.getBitwiseOpComp(topNet,vEndOutReg,notVEndOutReg,'NOT');

    pirelab.getBitwiseOpComp(topNet,[hEndOutReg,notVEndOutReg,hCountLine,vCountNotMax,validOutReg],vCountPre,'AND');
    pirelab.getUnitDelayComp(topNet,vCountPre,vCountEn,'vCountEnReg',0);

    pirelab.getCounterComp(topNet,[hCountRst,hCountEn],hCountCounter,...
    'Count limited',...
    1.0,...
    1.0,...
    2^hCountSize-1,...
    true,...
    false,...
    true,...
    false,...
    'horizcounter');
    pirelab.getCounterComp(topNet,[vCountRst,vCountEn],vCountCounter,...
    'Count limited',...
    1.0,...
    1.0,...
    2^vCountSize-1,...
    true,...
    false,...
    true,...
    false,...
    'vertcounter');



    pirelab.getSwitchComp(topNet,[hZero,hCountCounter],hCount,muxCtrl);
    pirelab.getSwitchComp(topNet,[vZero,vCountCounter],vCount,muxCtrl);

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

function signal=newSignalLike(topNet,name,refSignal)
    inType=refSignal(1).Type;
    rate=refSignal(1).SimulinkRate;

    if length(refSignal)>1
        for ii=1:length(refSignal)
            signal(ii)=topNet.addSignal(inType,[name,num2str(ii),'comp']);%#ok
            signal(ii).SimulinkRate=rate;%#ok
        end
    else
        signal=topNet.addSignal(inType,name);
        signal.SimulinkRate=rate;
    end
end




function[inFrame,inLine,newFrame,newLine,inFrameNext,inLineNext]=lineframeFSM(topNet,hS,hE,vS,vE,val,inRate,nameprefix)

    if nargin<8
        nameprefix='';
    end

    inFrame=newControlSignal(topNet,[nameprefix,'inFrame'],inRate);
    inLine=newControlSignal(topNet,[nameprefix,'inLine'],inRate);

    newLine=newControlSignal(topNet,[nameprefix,'newLine'],inRate);
    newFrame=newControlSignal(topNet,[nameprefix,'newFrame'],inRate);

    inFrameNext=newControlSignal(topNet,[nameprefix,'inFrameNext'],inRate);
    inFrameTerm1=newControlSignal(topNet,[nameprefix,'inFrame1Term'],inRate);
    inFrameTerm2=newControlSignal(topNet,[nameprefix,'inFrame2Term'],inRate);
    inFrameTerm3=newControlSignal(topNet,[nameprefix,'inFrame3Term'],inRate);

    inLineNext=newControlSignal(topNet,[nameprefix,'inLineNext'],inRate);
    inLineTerm1=newControlSignal(topNet,[nameprefix,'inLine1Term'],inRate);
    inLineTerm2=newControlSignal(topNet,[nameprefix,'inLine2Term'],inRate);
    inLineTerm3=newControlSignal(topNet,[nameprefix,'inLine3Term'],inRate);
    inLineTerm4=newControlSignal(topNet,[nameprefix,'inLine4Term'],inRate);
    inLineTerm5=newControlSignal(topNet,[nameprefix,'inLine5Term'],inRate);
    inLineTerm6=newControlSignal(topNet,[nameprefix,'inLine6Term'],inRate);

    vEndInv=newControlSignal(topNet,[nameprefix,'vEndInv'],inRate);
    pirelab.getBitwiseOpComp(topNet,vE,vEndInv,'NOT');

    hEndInv=newControlSignal(topNet,[nameprefix,'hEndInv'],inRate);
    pirelab.getBitwiseOpComp(topNet,hE,hEndInv,'NOT');

    validInv=newControlSignal(topNet,[nameprefix,'ValidInv'],inRate);
    pirelab.getBitwiseOpComp(topNet,val,validInv,'NOT');

    inFrameInv=newControlSignal(topNet,[nameprefix,'inFrameInv'],inRate);
    pirelab.getBitwiseOpComp(topNet,inFrame,inFrameInv,'NOT');

    inLineInv=newControlSignal(topNet,[nameprefix,'inLineInv'],inRate);
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
    pirelab.getBitwiseOpComp(topNet,[val,vS],inFrameTerm2,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInv,inFrame],inFrameTerm3,'AND');

    pirelab.getBitwiseOpComp(topNet,[hEndInv,inLine],inLineTerm1,'AND');
    pirelab.getBitwiseOpComp(topNet,[val,hS,vS],inLineTerm2,'AND');
    pirelab.getBitwiseOpComp(topNet,[vS,inLine],inLineTerm3,'AND');
    pirelab.getBitwiseOpComp(topNet,[inFrameInv,inLine],inLineTerm4,'AND');
    pirelab.getBitwiseOpComp(topNet,[validInv,inLine],inLineTerm5,'AND');
    pirelab.getBitwiseOpComp(topNet,[val,hS,vEndInv,inFrame,inLineInv],inLineTerm6,'AND');

    pirelab.getBitwiseOpComp(topNet,[inFrameNext,val,vS],newFrame,'AND');
    pirelab.getBitwiseOpComp(topNet,[inFrameNext,val,hS],newLine,'AND');
end


