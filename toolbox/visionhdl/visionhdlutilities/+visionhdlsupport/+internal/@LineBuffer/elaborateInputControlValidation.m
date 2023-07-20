function InputControlValidation=elaborateInputControlValidation(~,topNet,blockInfo,sigInfo,dataRate)








    booleanT=sigInfo.booleanT;


    inPortNames={'hStartIn','hEndIn','vStartIn','vEndIn','validIn'};
    inPortTypes=[booleanT,booleanT,booleanT,booleanT,booleanT];
    inPortRates=[dataRate,dataRate,dataRate,dataRate,dataRate];
    outPortNames={'hStartOut','hEndOut','vStartOut','vEndOut','validOut','InBetweenOut'};
    outPortTypes=[booleanT,booleanT,booleanT,booleanT,booleanT,booleanT];

    InputControlValidation=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','InputControlValidation',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=InputControlValidation.PirInputSignals;
    hStartIn=inSignals(1);
    hEndIn=inSignals(2);
    vStartIn=inSignals(3);
    vEndIn=inSignals(4);
    validIn=inSignals(5);


    outSignals=InputControlValidation.PirOutputSignals;
    hStartOut=outSignals(1);
    hEndOut=outSignals(2);
    vStartOut=outSignals(3);
    vEndOut=outSignals(4);
    validOut=outSignals(5);
    InBetweenOut=outSignals(6);










    [InFrame,InLine,~,~,InFramePrev,InLinePrev,InBetween]=lineframeFSM(InputControlValidation,...
    hStartIn,hEndIn,vStartIn,vEndIn,validIn,dataRate,'LineBuffer');

    hStartReg=newControlSignal(InputControlValidation,'hStartReg',dataRate);
    hEndReg=newControlSignal(InputControlValidation,'hEndReg',dataRate);
    vStartReg=newControlSignal(InputControlValidation,'vStartReg',dataRate);
    vEndReg=newControlSignal(InputControlValidation,'vEndReg',dataRate);
    validReg=newControlSignal(InputControlValidation,'validReg',dataRate);
    validPre=newControlSignal(InputControlValidation,'validPre',dataRate);
    validPost=newControlSignal(InputControlValidation,'validPost',dataRate);

    InFrameInLine=newControlSignal(InputControlValidation,'InFrameInLine',dataRate);
    InFrameInLinePrev=newControlSignal(InputControlValidation,'InFrameInLinePrev',dataRate);

    pirelab.getUnitDelayComp(InputControlValidation,hStartIn,hStartReg);

    pirelab.getUnitDelayComp(InputControlValidation,vStartIn,vStartReg);

    pirelab.getUnitDelayComp(InputControlValidation,validIn,validReg);

    pirelab.getLogicComp(InputControlValidation,[InFrame,InLine],InFrameInLine,'and','InFrameInLine');
    pirelab.getLogicComp(InputControlValidation,[InFramePrev,InLinePrev],InFrameInLinePrev,'and','InFrameInLine');

    pirelab.getLogicComp(InputControlValidation,[InFrameInLine,hStartReg],hStartOut,'and');
    pirelab.getLogicComp(InputControlValidation,[InFrameInLine,hEndIn],hEndOut,'and');
    pirelab.getLogicComp(InputControlValidation,[InFrameInLine,vStartReg],vStartOut,'and');
    pirelab.getLogicComp(InputControlValidation,[InFrameInLine,vEndIn],vEndOut,'and');
    pirelab.getLogicComp(InputControlValidation,[InFrameInLine,validReg],validPre,'and');
    pirelab.getLogicComp(InputControlValidation,[InFrameInLinePrev,validReg],validPost,'and');
    pirelab.getLogicComp(InputControlValidation,[validPre,validPost],validOut,'or');
    pirelab.getUnitDelayComp(InputControlValidation,InBetween,InBetweenOut);

end


function[inFrame,inLine,newFrame,newLine,inFramePrev,inLinePrev,InBetween]=lineframeFSM(topNet,hS,hE,vS,vE,val,inRate,nameprefix)

    if nargin<8
        nameprefix='';
    end

    inFrame=newControlSignal(topNet,[nameprefix,'inFrame'],inRate);
    inLine=newControlSignal(topNet,[nameprefix,'inLine'],inRate);
    NotInLine=newControlSignal(topNet,[nameprefix,'NotInLine'],inRate);
    InBetween=newControlSignal(topNet,[nameprefix,'InBetween'],inRate);


    inFramePrev=newControlSignal(topNet,[nameprefix,'inFramePrev'],inRate);
    inLinePrev=newControlSignal(topNet,[nameprefix,'inLinePrev'],inRate);

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

    pirelab.getLogicComp(topNet,inLine,NotInLine,'not');
    pirelab.getLogicComp(topNet,[NotInLine,inFrame],InBetween,'and');


    pirelab.getUnitDelayComp(topNet,inFrame,inFramePrev,'inFPReg',0);
    pirelab.getUnitDelayComp(topNet,inLine,inLinePrev,'inLPReg',0);

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

    pirelab.getBitwiseOpComp(topNet,[inFrameNext,inFrameInv],newFrame,'AND');
    pirelab.getBitwiseOpComp(topNet,[inLineNext,inLineInv],newLine,'AND');
end


function signal=newControlSignal(topNet,name,rate)
    controlType=pir_ufixpt_t(1,0);
    signal=topNet.addSignal(controlType,name);
    signal.SimulinkRate=rate;
end









