function elabHDLSinglePartlySerial(this,FIRDecimImpl,blockInfo)




    insignals=FIRDecimImpl.PirInputSignals;
    outsignals=FIRDecimImpl.PirOutputSignals;




    [FilterIn_DT,~]=getFilterOutDT(this,blockInfo);

    dataIn=insignals(1);
    dataRate=dataIn.simulinkRate;
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    DATAIN_ISCOMPLEX=dataInType.iscomplex;

    validIn=insignals(2);

    dataOut=outsignals(1);

    validOut=outsignals(2);


    filterOutType=dataOut.Type;


    if DATAIN_ISCOMPLEX
        DataInType=hdlcoder.tp_complex(FilterIn_DT);
    else
        DataInType=FilterIn_DT;
    end




    if blockInfo.inMode(2)
        syncReset=insignals(3);
        syncReset.SimulinkRate=dataRate;
    else
        syncReset=FIRDecimImpl.addSignal2('Type',pir_boolean_t,'Name','syncReset');
        syncReset.SimulinkRate=dataRate;
        if blockInfo.inResetSS


            syncReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
        else


            pirelab.getConstComp(FIRDecimImpl,syncReset,false);
        end
    end


    dataIn_cast=FIRDecimImpl.addSignal2('Type',DataInType,'Name','dataIn_cast');
    dataIn_cast.SimulinkRate=dataRate;

    dInReg=FIRDecimImpl.addSignal2('Type',DataInType,'Name','dInReg');
    dInReg.SimulinkRate=dataRate;
    vldReg=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
    'Name','vldReg','SimulinkRate',dataRate);
    rdyReg=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
    'Name','rdyReg','SimulinkRate',dataRate);


    pirelab.getDTCComp(FIRDecimImpl,dataIn,dataIn_cast);
    filteroutData=FIRDecimImpl.addSignal2('Type',filterOutType,...
    'Name','filterOut','SimulinkRate',dataRate);
    filteroutVld=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
    'Name','filterOut_vld','SimulinkRate',dataRate);
    blkInfo=getSinglePartlySerialInfo(this,blockInfo);

    if all(blkInfo.Numerator(:)==0)||all(fi(blkInfo.Numerator(:),numerictype(blkInfo.NumeratorQuantized))==0)


        c=pirelab.getConstComp(FIRDecimImpl,filteroutData,0);
        c.addComment(['All zero coefficient for phase ',num2str(ii)]);
    else
        pirelab.getIntDelayEnabledResettableComp(FIRDecimImpl,dataIn_cast,dInReg,'',syncReset,1);
        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
        '+dsphdlsupport','+internal','@FIRDecimator','cgireml','dropEarlyData.m'),'r');
        fcnBody=fread(fid,Inf,'char=>char')';
        fclose(fid);

        desc='dropEarlyData';

        dropEarlyData=FIRDecimImpl.addComponent2(...
        'kind','cgireml',...
        'Name','dropEarlyData',...
        'InputSignals',validIn,...
        'OutputSignals',[vldReg,rdyReg],...
        'EMLFileName','dropEarlyData',...
        'EMLFileBody',fcnBody,...
        'EMLParams',{blockInfo.DecimationFactor,blockInfo.NumCycles},...
        'ExternalSynchronousResetSignal',syncReset,...
        'EMLFlag_TreatInputIntsAsFixpt',true,...
        'EMLFlag_SaturateOnIntOverflow',false,...
        'EMLFlag_TreatInputBoolsAsUfix1',false,...
        'BlockComment',desc);

        dropEarlyData.runConcurrencyMaximizer(0);
        filteroutRdy=FIRDecimImpl.addSignal2('Type',pir_boolean_t,...
        'Name','filterOut_vld','SimulinkRate',dataRate);
        filterImpl=this.elabHDLPartlySerialFIR(FIRDecimImpl,blkInfo,...
        [dInReg,vldReg,syncReset],[filteroutData,filteroutVld,filteroutRdy]);
        pirelab.instantiateNetwork(FIRDecimImpl,filterImpl,...
        [dInReg,vldReg,syncReset],[filteroutData,filteroutVld,filteroutRdy],...
        'FIRDFilter');
    end

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@FIRDecimator','cgireml','downSampler.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='downSampler';

    dropEarlyData=FIRDecimImpl.addComponent2(...
    'kind','cgireml',...
    'Name','downSampler',...
    'InputSignals',[filteroutData,filteroutVld],...
    'OutputSignals',[dataOut,validOut],...
    'EMLFileName','downSampler',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{blockInfo.DecimationFactor},...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    dropEarlyData.runConcurrencyMaximizer(0);

end

