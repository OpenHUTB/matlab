function bcNet=elabBetaDecompressNetwork(this,topNet,blockInfo,dataRate)





    ufix1Type=pir_boolean_t;
    bType=pir_sfixpt_t(blockInfo.betaWL,blockInfo.alphaFL);
    bcType=pir_ufixpt_t(blockInfo.betaCompWL,0);
    bcType3=pir_ufixpt_t(blockInfo.betaIdxWL,0);
    bcType4=pir_ufixpt_t(2*blockInfo.minWL,0);
    mindtcType=pir_ufixpt_t(blockInfo.minWL,0);
    sminType=pir_ufixpt_t(blockInfo.betaWL,blockInfo.alphaFL);

    sType=pirelab.getPirVectorType(ufix1Type,blockInfo.memDepth);
    betaVType=pirelab.getPirVectorType(bType,blockInfo.memDepth);
    bcVType=pirelab.getPirVectorType(bcType,blockInfo.memDepth);
    bcVType3=pirelab.getPirVectorType(bcType3,blockInfo.memDepth);
    bcVType4=pirelab.getPirVectorType(bcType4,blockInfo.memDepth);
    sminVType=pirelab.getPirVectorType(sminType,blockInfo.memDepth);
    dtcVType=pirelab.getPirVectorType(mindtcType,blockInfo.memDepth);

    if blockInfo.memDepth==64
        cType=pir_ufixpt_t(7,0);
        cVType=pirelab.getPirVectorType(cType,blockInfo.memDepth);
    else
        cType=pir_ufixpt_t(5,0);
        cVType=pirelab.getPirVectorType(cType,blockInfo.memDepth);
    end


    bcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','BetaDecompress',...
    'Inportnames',{'betacomp1','betacomp2','betacomp3','betacomp4','validin','count','reset','rdenable'},...
    'InportTypes',[bcVType,bcVType,bcVType3,bcVType4,ufix1Type,cType,ufix1Type,sType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'Outportnames',{'beta','valid'},...
    'OutportTypes',[betaVType,ufix1Type]...
    );



    betacomp1=bcNet.PirInputSignals(1);
    betacomp2=bcNet.PirInputSignals(2);
    betacomp3=bcNet.PirInputSignals(3);
    betacomp4=bcNet.PirInputSignals(4);
    validin=bcNet.PirInputSignals(5);
    count=bcNet.PirInputSignals(6);
    reset=bcNet.PirInputSignals(7);
    rdenb=bcNet.PirInputSignals(8);

    betaout=bcNet.PirOutputSignals(1);
    validout=bcNet.PirOutputSignals(2);
    z=2*(blockInfo.minWL);
    y=blockInfo.minWL-1;



    if blockInfo.memDepth==64
        maxCount=64;
        for i=1:32
            sign(i)=bcNet.addSignal(sType,['sign_',num2str(i)]);%#ok<*AGROW> 
            pirelab.getBitSliceComp(bcNet,betacomp1,sign(i),32-i,32-i,['extSign_',num2str(i)]');
        end
        for i=33:64
            sign(i)=bcNet.addSignal(sType,['sign_',num2str(i)]);
            pirelab.getBitSliceComp(bcNet,betacomp2,sign(i),64-i,64-i,['extSign_',num2str(i)]');
        end
        x=[];
        for idx=1:64
            x=[x,sign(idx)];
        end
        x=[x,sign(1)];
    else

        maxCount=31;
        for i=1:31
            sign(i)=bcNet.addSignal(sType,['sign_',num2str(i)]);%#ok<*AGROW>
            pirelab.getBitSliceComp(bcNet,betacomp1,sign(i),31-i,31-i,['extSign_',num2str(i)]');
        end
        x=[];
        for idx=1:31
            x=[x,sign(idx)];
        end
        x=[x,sign(1)];
    end

    prodsign=bcNet.addSignal(sType,'prodsign');
    pirelab.getBitSliceComp(bcNet,betacomp3,prodsign,blockInfo.betaIdxWL-1,blockInfo.betaIdxWL-1,'ext_prodsign');

    min_index=bcNet.addSignal(cVType,'min_index');
    pirelab.getBitSliceComp(bcNet,betacomp3,min_index,blockInfo.betaIdxWL-2,0,'ext_minindex');

    min1_dtc=bcNet.addSignal(dtcVType,'min1_dtc');
    min2_dtc=bcNet.addSignal(dtcVType,'min2_dtc');
    smin1=bcNet.addSignal(sminVType,'sMin1');
    smin2=bcNet.addSignal(sminVType,'sMin2');

    pirelab.getBitSliceComp(bcNet,betacomp4,min2_dtc,y,0,'ext_min2');
    pirelab.getDTCComp(bcNet,min2_dtc,smin2,'Floor','Wrap','SI');

    pirelab.getBitSliceComp(bcNet,betacomp4,min1_dtc,z-1,y+1,'ext_min1');
    pirelab.getDTCComp(bcNet,min1_dtc,smin1,'Floor','Wrap','SI');



    rstcount=bcNet.addSignal(ufix1Type,'resetCount');
    countmax=bcNet.addSignal(ufix1Type,'countMax');
    count1=bcNet.addSignal(count.Type,'countVal');

    const1=bcNet.addSignal(ufix1Type,'const1');
    pirelab.getConstComp(bcNet,const1,1);

    countadd=bcNet.addSignal(count.Type,'countIdx');
    pirelab.getAddComp(bcNet,[count,const1],countadd,'Floor','Wrap','AddComp');
    count1_reg=bcNet.addSignal(count.Type,'countValReg');
    pirelab.getRelOpComp(bcNet,[countadd,count1_reg],countmax,'==');
    pirelab.getLogicComp(bcNet,[countmax,reset],rstcount,'or');


    enbcount=bcNet.addSignal(ufix1Type,'enbCount');
    pirelab.getUnitDelayEnabledResettableComp(bcNet,validin,enbcount,validin,rstcount,'',0);

    enbcnt=bcNet.addSignal(ufix1Type,'enbCountReg');
    pirelab.getLogicComp(bcNet,[validin,enbcount],enbcnt,'or');


    pirelab.getWireComp(bcNet,enbcount,validout,'');
    pirelab.getCounterComp(bcNet,[rstcount,enbcnt],count1,'Count limited',0,1,maxCount,1,0,1,0,'counter',0);
    pirelab.getUnitDelayComp(bcNet,count1,count1_reg,'',0);




    signdata=bcNet.addSignal(sType,'signs');
    pirelab.getMultiPortSwitchComp(bcNet,[count1,x],signdata,1,1,'Floor','Wrap');

    beta=bcNet.addSignal(betaout.Type,'beta');
    beta_reg=bcNet.addSignal(beta.Type,'betaReg');
    beta_mux=bcNet.addSignal(betaout.Type,'betaMux');

    bcalNet=this.elabBetaCalculationNetwork(bcNet,blockInfo,dataRate);
    bcalNet.addComment('Beta Calculation Unit');
    pirelab.instantiateNetwork(bcNet,bcalNet,[signdata,prodsign,min_index,smin1,smin2,count1],...
    beta_reg,'BetaCalUnit');

    zerodata=bcNet.addSignal(bType,'zeroData');
    pirelab.getConstComp(bcNet,zerodata,0);
    pirelab.getUnitDelayComp(bcNet,beta_reg,beta_mux,'beta',0);
    barray=this.demuxSignal(bcNet,beta_mux,'betaArray');

    rdenbarray=this.demuxSignal(bcNet,rdenb,'rdEnbArray');

    for idx1=1:blockInfo.memDepth
        bdarray(idx1)=bcNet.addSignal(bType,['betaArray_',num2str(idx1)]);
        pirelab.getSwitchComp(bcNet,[barray(idx1),zerodata],bdarray(idx1),rdenbarray(idx1),'Switch','==',1);
    end

    this.muxSignal(bcNet,bdarray,betaout);


