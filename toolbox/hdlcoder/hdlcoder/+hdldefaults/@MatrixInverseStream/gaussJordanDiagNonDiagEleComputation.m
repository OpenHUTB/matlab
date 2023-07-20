
function gaussJordanDiagNonDiagEleComputation(this,hN,NonDiagEleComputationInSigs,NonDiagEleComputationOutSigs,...
    hBoolT,hCounterT,hInputDataT,slRate,blockInfo)





    hNonDiagEleComputationN=pirelab.createNewNetwork(...
    'Name','NonDiagEleComputation',...
    'InportNames',{'diagReciprocalDataReg','reciprocalValidOutReg','nonDiagValidInReg','diagValidCount','rowCount','readDataReg','nonDiagValidInCount','colCountOutReg'},...
    'InportTypes',[NonDiagEleComputationInSigs(1).Type,hBoolT,hBoolT,hCounterT,hCounterT,NonDiagEleComputationInSigs(6).Type,hCounterT,hCounterT],...
    'InportRates',slRate*ones(1,8),...
    'OutportNames',{'nonDiagDataOut1','colCountOut','nonDiagDataOut2','diagDataOut1','diagDataOut2','nonDiagValidOut','diagValidOut'},...
    'OutportTypes',[hInputDataT,hCounterT,hInputDataT,hInputDataT,hInputDataT,hBoolT,hBoolT]);

    hNonDiagEleComputationN.setTargetCompReplacementCandidate(true);

    for ii=1:numel(hNonDiagEleComputationN.PirOutputSignals)
        hNonDiagEleComputationN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hNonDiagEleComputationNinSigs=hNonDiagEleComputationN.PirInputSignals;
    hNonDiagEleComputationNoutSigs=hNonDiagEleComputationN.PirOutputSignals;

    diagReciprocalDataReg=hNonDiagEleComputationNinSigs(1);
    reciprocalValidOutReg=hNonDiagEleComputationNinSigs(2);
    nonDiagValidInReg=hNonDiagEleComputationNinSigs(3);
    diagValidCount=hNonDiagEleComputationNinSigs(4);
    rowCount=hNonDiagEleComputationNinSigs(5);
    readDataReg=hNonDiagEleComputationNinSigs(6);
    nonDiagValidInCount=hNonDiagEleComputationNinSigs(7);
    colCountOutReg=hNonDiagEleComputationNinSigs(8);

    nonDiagDataOut1=hNonDiagEleComputationNoutSigs(1);
    colCountOut=hNonDiagEleComputationNoutSigs(2);
    nonDiagDataOut2=hNonDiagEleComputationNoutSigs(3);
    diagDataOut1=hNonDiagEleComputationNoutSigs(4);
    diagDataOut2=hNonDiagEleComputationNoutSigs(5);
    nonDiagValidOut=hNonDiagEleComputationNoutSigs(6);
    diagValidOut=hNonDiagEleComputationNoutSigs(7);

    if blockInfo.MatrixSize==1
        hArrayT=hInputDataT;
    else
        hArrayT=pirelab.createPirArrayType(hInputDataT,[blockInfo.MatrixSize,0]);
    end

    multiplyDivideInpOne=l_addSignal(hNonDiagEleComputationN,'multiplyDivideInpOne',hInputDataT,slRate);
    multiplyDivideInpTwo=l_addSignal(hNonDiagEleComputationN,'multiplyDivideInpTwo',hInputDataT,slRate);
    multiplyDivideInpTwoEyeMem=l_addSignal(hNonDiagEleComputationN,'multiplyDivideInpTwoEyeMem',hInputDataT,slRate);
    subtractFirstInp=l_addSignal(hNonDiagEleComputationN,'subtractFirstInp',hInputDataT,slRate);
    subtractFirstInpEyeMem=l_addSignal(hNonDiagEleComputationN,'subtractFirstInpEyeMem',hInputDataT,slRate);

    diagOutStoredData=l_addSignal(hNonDiagEleComputationN,'diagOutStoredData',...
    hArrayT,slRate);

    diagOutStoredDataEyeMem=l_addSignal(hNonDiagEleComputationN,'diagOutStoredDataEyeMem',...
    hArrayT,slRate);
    rowCountReg=l_addSignal(hNonDiagEleComputationN,'rowCountReg',hCounterT,slRate);




    pirTyp2=pir_boolean_t;
    pirTyp3=hCounterT;

    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');

    nt1=numerictype(0,ceil(log2(blockInfo.MatrixSize))+1,0);





    Delay22_out1_s8=l_addSignal(hNonDiagEleComputationN,'Delay22_out1',pirTyp3,slRate);
    Delay9_out1_s11=l_addSignal(hNonDiagEleComputationN,'Delay9_out1',pirTyp3,slRate);

    Delay5_out_s25=l_addSignal(hNonDiagEleComputationN,'Delay5_out',pirTyp3,slRate);
    Delay5_Initial_Val_out_s26=l_addSignal(hNonDiagEleComputationN,'Delay5_Initial_Val_out',pirTyp3,slRate);
    Delay5_ctrl_const_out_s27=l_addSignal(hNonDiagEleComputationN,'Delay5_ctrl_const_out',pirTyp2,slRate);
    Delay5_ctrl_delay_out_s28=l_addSignal(hNonDiagEleComputationN,'Delay5_ctrl_delay_out',pirTyp2,slRate);

    if strcmpi(blockInfo.latencyStrategy,'MAX')
        if strcmpi(blockInfo.inputDataType,'SINGLE')
            latencyBalanceMul=8;
        else
            latencyBalanceMul=9;
        end
        latencyBalanceAddSub=11;
    elseif strcmpi(blockInfo.latencyStrategy,'MIN')
        latencyBalanceMul=6;
        latencyBalanceAddSub=6;
    else
        latencyBalanceMul=0;
        latencyBalanceAddSub=0;
    end


    pirelab.getIntDelayComp(hNonDiagEleComputationN,...
    Delay9_out1_s11,...
    Delay22_out1_s8,...
    latencyBalanceMul,'Delay22',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);



    pirelab.getIntDelayComp(hNonDiagEleComputationN,...
    Delay22_out1_s8,...
    colCountOut,...
    latencyBalanceAddSub,'Delay26',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);



    pirelab.getIntDelayComp(hNonDiagEleComputationN,...
    rowCount,...
    Delay5_out_s25,...
    1,'Delay5',...
    0,...
    0,0,[],0,0);



    pirelab.getIntDelayComp(hNonDiagEleComputationN,...
    colCountOutReg,...
    Delay9_out1_s11,...
    1,'Delay9',...
    fi(0,nt1,fiMath1,'hex','0'),...
    0,0,[],0,0);


    pirelab.getConstComp(hNonDiagEleComputationN,...
    Delay5_Initial_Val_out_s26,...
    1,...
    'Delay5_Initial_Val','on',0,'','','');

    pirelab.getConstComp(hNonDiagEleComputationN,...
    Delay5_ctrl_const_out_s27,...
    1,...
    'Delay5_ctrl_const');

    pirelab.getIntDelayComp(hNonDiagEleComputationN,...
    Delay5_ctrl_const_out_s27,...
    Delay5_ctrl_delay_out_s28,...
    1,'Delay5_ctrl_delay',...
    0,...
    0,0,[],0,0);

    pirelab.getSwitchComp(hNonDiagEleComputationN,...
    [Delay5_out_s25,Delay5_Initial_Val_out_s26],...
    rowCountReg,...
    Delay5_ctrl_delay_out_s28,'Delay5_switch',...
    '~=',0,'Floor','Wrap');









    multiplyDivideInpOneSelInSigs=[rowCountReg,reciprocalValidOutReg,diagReciprocalDataReg,readDataReg];
    multiplyDivideInpOneSelOutSigs=multiplyDivideInpOne;

    this.multiplyDivideInpOneSelector(hNonDiagEleComputationN,multiplyDivideInpOneSelInSigs,...
    multiplyDivideInpOneSelOutSigs,hCounterT,hInputDataT,hBoolT,slRate,blockInfo);



    multiplyDivideInpTwoSelInSigs=[reciprocalValidOutReg,diagValidCount,readDataReg,diagOutStoredData,nonDiagValidInReg,nonDiagValidInCount,diagOutStoredDataEyeMem];
    multiplyDivideInpTwoSelOutSigs=[multiplyDivideInpTwo,multiplyDivideInpTwoEyeMem];

    this.multiplyDivideInpTwoSelector(hNonDiagEleComputationN,multiplyDivideInpTwoSelInSigs,...
    multiplyDivideInpTwoSelOutSigs,hCounterT,hInputDataT,hBoolT,slRate,blockInfo);


    subtractFirstInpSelInSigs=[nonDiagValidInCount,readDataReg];
    subtractFirstInpSelOutSigs=[subtractFirstInp,subtractFirstInpEyeMem];

    this.subtractFirstInputSelector(hNonDiagEleComputationN,subtractFirstInpSelInSigs,...
    subtractFirstInpSelOutSigs,hCounterT,hInputDataT,slRate,blockInfo);


    diagDataComputationInSigs=[diagValidCount,reciprocalValidOutReg,multiplyDivideInpTwo,multiplyDivideInpOne,multiplyDivideInpTwoEyeMem];
    diagDataComputationOutSigs=[diagDataOut1,diagDataOut2,diagValidOut,diagOutStoredData,diagOutStoredDataEyeMem];

    this.gaussJordanDiagDataComputation(hNonDiagEleComputationN,diagDataComputationInSigs,...
    diagDataComputationOutSigs,hCounterT,hInputDataT,hBoolT,slRate,blockInfo);


    nonDiagDataComputationInSigs=[nonDiagValidInReg,subtractFirstInp,subtractFirstInpEyeMem,multiplyDivideInpOne,multiplyDivideInpTwo,multiplyDivideInpTwoEyeMem];
    nonDiagDataComputationOutSigs=[nonDiagValidOut,nonDiagDataOut1,nonDiagDataOut2];

    this.gaussJordanNonDiagDataComputation(hNonDiagEleComputationN,nonDiagDataComputationInSigs,...
    nonDiagDataComputationOutSigs,hBoolT,slRate,blockInfo);



    pirelab.instantiateNetwork(hN,hNonDiagEleComputationN,NonDiagEleComputationInSigs,...
    NonDiagEleComputationOutSigs,[hNonDiagEleComputationN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


