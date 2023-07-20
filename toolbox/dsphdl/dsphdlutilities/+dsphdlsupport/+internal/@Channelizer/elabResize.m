function reSizeImpl=elabResize(this,TopNet,blockInfo,dataRate,...
    dataIn,VldIn,syncReset,varargin)






    reSizeImpl=TopNet;
    outputs=varargin{1};

    dataInType=pirgetdatatypeinfo(dataIn.Type);
    dataInSize=dataInType.dims;

    dataOut=outputs(1);
    dataOutType=pirgetdatatypeinfo(dataOut(1).Type);
    reSizeOutSize=dataOutType.dims;
    if dataOutType.iscomplex
        baseType=pir_fixpt_t(1,dataOutType.wordsize,dataOutType.binarypoint);
        reSizeOutType=hdlcoder.tp_complex(baseType);
    else
        reSizeOutType=pir_fixpt_t(1,dataOutType.wordsize,dataOutType.binarypoint);
    end

    OutSignal=reSizeImpl.addSignal2('Type',dataOut.Type,'Name','OutSignal');
    OutSignal.SimulinkRate=dataRate;
    VldOut=reSizeImpl.addSignal2('Type',pir_boolean_t,'Name','VldOut');
    VldOut.SimulinkRate=dataRate;

    CNT_WORDLENGTH=reSizeOutSize/dataInSize;
    enbVector=reSizeImpl.addSignal2('Type',pir_fixpt_t(0,CNT_WORDLENGTH,0),'Name','enbVector');
    enbVector.SimulinkRate=dataRate;

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@Channelizer','cgireml','reSizeCtrl.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='reSizeCtrl';

    reSize=reSizeImpl.addComponent2(...
    'kind','cgireml',...
    'Name','reSizeCtrl',...
    'InputSignals',VldIn,...
    'OutputSignals',[enbVector,VldOut],...
    'EMLFileName','reSizeCtrl',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{CNT_WORDLENGTH},...
    'ExternalSynchronousResetSignal',syncReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    reSize.runConcurrencyMaximizer(0);



    loop=0;
    ZeroSignal=reSizeImpl.addSignal2('Type',reSizeOutType,'Name','ZeroSignla');%#ok<*AGROW>
    ZeroSignal.SimulinkRate=dataRate;
    pirelab.getConstComp(reSizeImpl,ZeroSignal,0);
    for loop1=1:reSizeOutSize/dataInSize
        enb=reSizeImpl.addSignal2('Type',pir_fixpt_t(0,1,0),'Name',['enb_',int2str(loop1)]);
        enb.SimulinkRate=dataRate;
        index=loop1-1;
        pirelab.getBitSliceComp(reSizeImpl,enbVector,enb,index,index);
        for loop2=1:dataInSize
            loop=loop+1;
            dReg(loop,1)=reSizeImpl.addSignal2('Type',reSizeOutType,'Name',['dReg_',num2str(loop-1)]);%#ok<*AGROW>
            dReg(loop,1).SimulinkRate=dataRate;
            if dataInSize==1
                splitSignal=dataIn;
            else
                splitSignal=dataIn.split.PirOutputSignals(loop2);
            end
            pirelab.getIntDelayEnabledResettableComp(reSizeImpl,splitSignal,dReg(loop,1),enb,syncReset,1);
        end
    end

    dReg=dReg(bitrevorder(1:reSizeOutSize));

    for loop=1:length(dReg)
        dMuxOut=reSizeImpl.addSignal2('Type',reSizeOutType,'Name','dMuxOut');%#ok<*AGROW>
        dMuxOut.SimulinkRate=dataRate;
        dRegOut(loop,1)=reSizeImpl.addSignal2('Type',reSizeOutType,'Name',['dRegOut_',num2str(loop-1)]);%#ok<*AGROW>
        pirelab.getSwitchComp(reSizeImpl,[dReg(loop,1),ZeroSignal],dMuxOut,VldOut,'','==',1);
        dRegOut(loop,1).SimulinkRate=dataRate;
        pirelab.getIntDelayEnabledResettableComp(reSizeImpl,dMuxOut,dRegOut(loop,1),'',syncReset,1);

    end

    VldOutReg=reSizeImpl.addSignal2('Type',pir_boolean_t,'Name','VldOutReg');
    VldOutReg.SimulinkRate=dataRate;
    pirelab.getIntDelayEnabledResettableComp(reSizeImpl,VldOut,VldOutReg,'','',1);


    if reSizeOutSize==1
        pirelab.getWireComp(reSizeImpl,dRegOut,outputs(1));
    else
        pirelab.getMuxComp(reSizeImpl,dRegOut,OutSignal);
        pirelab.getWireComp(reSizeImpl,OutSignal,outputs(1));
    end
    if blockInfo.outMode(1)&&blockInfo.outMode(2)
        pirelab.getWireComp(reSizeImpl,VldOutReg,outputs(2));
        pirelab.getWireComp(reSizeImpl,VldOutReg,outputs(3));
        pirelab.getWireComp(reSizeImpl,VldOutReg,outputs(4));
    elseif blockInfo.outMode(1)
        pirelab.getWireComp(reSizeImpl,VldOutReg,outputs(2));
        pirelab.getWireComp(reSizeImpl,VldOutReg,outputs(3));

    elseif blockInfo.outMode(2)
        pirelab.getWireComp(reSizeImpl,VldOutReg,outputs(2));
        pirelab.getWireComp(reSizeImpl,VldOutReg,outputs(3));

    else
        pirelab.getWireComp(reSizeImpl,VldOutReg,outputs(2));
    end
end
