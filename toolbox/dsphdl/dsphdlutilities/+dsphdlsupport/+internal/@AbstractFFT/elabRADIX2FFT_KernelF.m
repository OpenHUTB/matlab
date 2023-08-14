function stage1=elabRADIX2FFT_KernelF(this,topNet,blockInfo,stageNum,PROCESS_DELAY,dataRate,din_re,din_im,din_vld,softReset,dout_re,dout_im,dout_vld)






    InportNames={din_re.Name,din_im.Name,din_vld.Name,softReset.Name};
    InportTypes=[din_re.Type;din_im.Type;din_vld.Type;softReset.Type];
    InportRates=[dataRate;dataRate;dataRate;dataRate];


    stage1=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',['RADIX2FFT_KernelF_',num2str(stageNum)],...
    'InportNames',InportNames,...
    'InportTypes',InportTypes,...
    'InportRates',InportRates,...
    'OutportNames',{dout_re.Name,dout_im.Name,dout_vld.Name},...
    'OutportTypes',[dout_re.Type;dout_im.Type;dout_vld.Type]...
    );

    inputPort=stage1.PirInputSignals;
    outputPort=stage1.PirOutputSignals;

    if inputPort(1).Type.WordLength==outputPort(1).Type.WordLength
        din_re=inputPort(1);
        din_im=inputPort(2);
    else
        din_re=stage1.addSignal2('Type',dout_re.Type,'Name','din_re');
        din_re.SimulinkRate=dataRate;
        din_im=stage1.addSignal2('Type',dout_im.Type,'Name','din_im');
        din_im.SimulinkRate=dataRate;

        pirelab.getDTCComp(stage1,inputPort(1),din_re);
        pirelab.getDTCComp(stage1,inputPort(2),din_im);
    end
    din_vld=inputPort(3);

    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        softReset=inputPort(4);
    else
        softReset='';
    end



    dout_re=outputPort(1);
    dout_im=outputPort(2);
    dout_vld=outputPort(3);

    FFTLENGTH=blockInfo.actualFFTLength;
    TOTALSTAGES=log2(FFTLENGTH);
    SIGNED=dout_re.Type.Signed;
    WORDLENGTH=dout_re.Type.WordLength;
    FRACTIONLENGTH=dout_re.Type.FractionLength;
    ADDRWIDTH=log2(blockInfo.actualFFTLength)-stageNum;
    ADDRRANGE=blockInfo.actualFFTLength/2^stageNum-1;
    TWDL_WORDLENGTH=blockInfo.TWDL_WORDLENGTH;
    TWDL_FRACTIONLENGTH=-blockInfo.TWDL_FRACTIONLENGTH;

    if PROCESS_DELAY<=3
        DLYMEM_ADDRWIDTH=3;
    else
        DLYMEM_ADDRWIDTH=floor(log2(PROCESS_DELAY))+ceil(mod(log2(PROCESS_DELAY),2));
    end

    x_re_0=stage1.addSignal2('Type',dout_re.Type,'Name','x_re_0');
    x_re_0.SimulinkRate=dataRate;
    x_im_0=stage1.addSignal2('Type',dout_im.Type,'Name','x_im_0');
    x_im_0.SimulinkRate=dataRate;
    x_re_1=stage1.addSignal2('Type',dout_re.Type,'Name','x_re_1');
    x_re_1.SimulinkRate=dataRate;
    x_im_1=stage1.addSignal2('Type',dout_im.Type,'Name','x_im_1');
    x_im_1.SimulinkRate=dataRate;
    wrEnb_0=stage1.addSignal2('Type',pir_boolean_t,'Name','WrEnb_0');
    wrEnb_0.SimulinkRate=dataRate;
    wrAddr_0=stage1.addSignal2('Type',pir_ufixpt_t(ADDRWIDTH,0),'Name','wrAddr_0');
    wrAddr_0.SimulinkRate=dataRate;
    wrEnb_1=stage1.addSignal2('Type',pir_boolean_t,'Name','WrEnb_1');
    wrEnb_1.SimulinkRate=dataRate;
    wrAddr_1=stage1.addSignal2('Type',pir_ufixpt_t(DLYMEM_ADDRWIDTH,0),'Name','wrAddr_1');
    wrAddr_1.SimulinkRate=dataRate;
    wrData_re_0=stage1.addSignal2('Type',dout_re.Type,'Name','wrData_re_0');
    wrData_re_0.SimulinkRate=dataRate;
    wrData_im_0=stage1.addSignal2('Type',dout_re.Type,'Name','wrData_im_0');
    wrData_im_0.SimulinkRate=dataRate;
    wrData_re_1=stage1.addSignal2('Type',dout_re.Type,'Name','wrData_re_1');
    wrData_re_1.SimulinkRate=dataRate;
    wrData_im_1=stage1.addSignal2('Type',dout_re.Type,'Name','wrData_im_1');
    wrData_im_1.SimulinkRate=dataRate;
    dataRdEnb=stage1.addSignal2('Type',pir_boolean_t(),'Name','dataRdEnb');
    dataRdEnb.SimulinkRate=dataRate;

    rdAddr_0=stage1.addSignal2('Type',pir_ufixpt_t(ADDRWIDTH,0),'Name','rdAddr_0');
    rdAddr_0.SimulinkRate=dataRate;
    rdAddr_1=stage1.addSignal2('Type',pir_ufixpt_t(DLYMEM_ADDRWIDTH,0),'Name','rdAddr_1');
    rdAddr_1.SimulinkRate=dataRate;
    dIn_Vld=stage1.addSignal2('Type',pir_boolean_t(),'Name','dIn_Vld');
    dIn_Vld.SimulinkRate=dataRate;
    twdlRdEnb=stage1.addSignal2('Type',pir_boolean_t(),'Name','twdlRdEnb');
    twdlRdEnb.SimulinkRate=dataRate;
    useDlyData=stage1.addSignal2('Type',pir_boolean_t(),'Name','useDlyData');
    useDlyData.SimulinkRate=dataRate;



    if blockInfo.InputDataIsReal&&wrAddr_0.Type.WordLength>1&&stageNum==1
        if blockInfo.inverseFFT
            pirelab.getSimpleDualPortRamComp(stage1,[wrData_im_0,wrAddr_0,wrEnb_0,rdAddr_0],x_im_0,['dataMEM_im_0_',num2str(stageNum)]);
            pirelab.getWireComp(stage1,din_re,x_re_0);
        else
            pirelab.getSimpleDualPortRamComp(stage1,[wrData_re_0,wrAddr_0,wrEnb_0,rdAddr_0],x_re_0,['dataMEM_re_0_',num2str(stageNum)]);
            pirelab.getWireComp(stage1,din_im,x_im_0);
        end
        if blockInfo.inverseFFT
            pirelab.getSimpleDualPortRamComp(stage1,[wrData_im_1,wrAddr_1,wrEnb_1,rdAddr_1],x_im_1,['dataXMEM_im_1_',num2str(stageNum)]);
            pirelab.getWireComp(stage1,wrData_re_1,x_re_1);
        else
            pirelab.getSimpleDualPortRamComp(stage1,[wrData_re_1,wrAddr_1,wrEnb_1,rdAddr_1],x_re_1,['dataXMEM_re_1_',num2str(stageNum)]);
            pirelab.getWireComp(stage1,wrData_im_1,x_im_1);
        end

    else
        if wrAddr_0.Type.WordLength==1
            fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
            '+dsphdlsupport','+internal','@AbstractFFT','cgireml','twoLocationReg.m'),'r');
            fcnBody=fread(fid,Inf,'char=>char')';
            fclose(fid);

            desc='twoLocationReg_0';

            twoLocationReg_0=stage1.addComponent2(...
            'kind','cgireml',...
            'Name','twoLocationReg_0',...
            'InputSignals',[wrData_re_0,wrData_im_0,wrAddr_0,wrEnb_0,rdAddr_0],...
            'OutputSignals',[x_re_0,x_im_0],...
            'ExternalSynchronousResetSignal',softReset,...
            'EMLFileName','twoLocationReg',...
            'EMLFileBody',fcnBody,...
            'EMLParams',{WORDLENGTH,FRACTIONLENGTH},...
            'EMLFlag_TreatInputIntsAsFixpt',true,...
            'EMLFlag_SaturateOnIntOverflow',false,...
            'EMLFlag_TreatInputBoolsAsUfix1',false,...
            'BlockComment',desc);

            twoLocationReg_0.runConcurrencyMaximizer(0);
        else
            pirelab.getSimpleDualPortRamComp(stage1,[wrData_re_0,wrAddr_0,wrEnb_0,rdAddr_0],x_re_0,['dataMEM_re_0_',num2str(stageNum)]);
            pirelab.getSimpleDualPortRamComp(stage1,[wrData_im_0,wrAddr_0,wrEnb_0,rdAddr_0],x_im_0,['dataMEM_im_0_',num2str(stageNum)]);
        end
        pirelab.getSimpleDualPortRamComp(stage1,[wrData_re_1,wrAddr_1,wrEnb_1,rdAddr_1],x_re_1,['dataXMEM_re_1_',num2str(stageNum)]);
        pirelab.getSimpleDualPortRamComp(stage1,[wrData_im_1,wrAddr_1,wrEnb_1,rdAddr_1],x_im_1,['dataXMEM_im_1_',num2str(stageNum)]);
    end

    x_out=stage1.addSignal2('Type',dout_re.Type,'Name','x_out');
    x_out.SimulinkRate=dataRate;
    y_out=stage1.addSignal2('Type',dout_re.Type,'Name','y_out');
    y_out.SimulinkRate=dataRate;
    u_out=stage1.addSignal2('Type',dout_re.Type,'Name','u_out');
    u_out.SimulinkRate=dataRate;
    v_out=stage1.addSignal2('Type',dout_re.Type,'Name','v_out');
    v_out.SimulinkRate=dataRate;

    doutVld=stage1.addSignal2('Type',pir_boolean_t(),'Name','doutVld');
    doutVld.SimulinkRate=dataRate;


    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','wrStateMachineF.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='wrStateMachineF';

    wrStateMachineF=stage1.addComponent2(...
    'kind','cgireml',...
    'Name','wrStateMachineF',...
    'InputSignals',[din_re,din_im,din_vld,y_out,v_out,doutVld],...
    'OutputSignals',[wrData_re_0,wrData_im_0,wrEnb_0,wrAddr_0,wrData_re_1,wrData_im_1,wrEnb_1,wrAddr_1],...
    'ExternalSynchronousResetSignal',softReset,...
    'EMLFileName','wrStateMachineF',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{FFTLENGTH,WORDLENGTH,FRACTIONLENGTH,ADDRWIDTH,ADDRRANGE,PROCESS_DELAY},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    wrStateMachineF.runConcurrencyMaximizer(0);




    dOutVld_0=stage1.addSignal2('Type',pir_boolean_t(),'Name','dOutVld2O');
    dOutVld_0.SimulinkRate=dataRate;
    dOutVld_1=stage1.addSignal2('Type',pir_boolean_t(),'Name','dOutVld_1');
    dOutVld_1.SimulinkRate=dataRate;
    procEnb=stage1.addSignal2('Type',pir_boolean_t(),'Name','procEnb');
    procEnb.SimulinkRate=dataRate;
    txEOF=stage1.addSignal2('Type',pir_boolean_t(),'Name','txEOF');
    txEOF.SimulinkRate=dataRate;

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','rdStateMachineF.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='rdStateMachineF';

    rdStateMachineF=stage1.addComponent2(...
    'kind','cgireml',...
    'Name','rdStateMachineF',...
    'InputSignals',[din_vld,doutVld,txEOF],...
    'OutputSignals',[rdAddr_0,rdAddr_1,dOutVld_0,dOutVld_1,procEnb],...
    'ExternalSynchronousResetSignal',softReset,...
    'EMLFileName','rdStateMachineF',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{ADDRWIDTH,ADDRRANGE,PROCESS_DELAY},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);


    rdStateMachineF.runConcurrencyMaximizer(0);


    if stageNum<=2
        in2_re=stage1.addSignal2('Type',pir_sfixpt_t(WORDLENGTH,FRACTIONLENGTH),'Name','in2_re');
        in2_re.SimulinkRate=dataRate;
        in2_im=stage1.addSignal2('Type',pir_sfixpt_t(WORDLENGTH,FRACTIONLENGTH),'Name','in2_im');
        in2_im.SimulinkRate=dataRate;
    else
        in2_re=stage1.addSignal2('Type',pir_sfixpt_t(WORDLENGTH+TWDL_WORDLENGTH+1,FRACTIONLENGTH+TWDL_FRACTIONLENGTH),'Name','in2_re');
        in2_re.SimulinkRate=dataRate;
        in2_im=stage1.addSignal2('Type',pir_sfixpt_t(WORDLENGTH+TWDL_WORDLENGTH+1,FRACTIONLENGTH+TWDL_FRACTIONLENGTH),'Name','in2_im');
        in2_im.SimulinkRate=dataRate;
    end


    if stageNum==3
        twdlFactor=fi(real(exp(1i*pi/4)),1,TWDL_WORDLENGTH,-TWDL_FRACTIONLENGTH,'RoundingMethod','Convergent','OverflowAction','Wrap');
        CONST07P=fi(twdlFactor,1,TWDL_WORDLENGTH,-TWDL_FRACTIONLENGTH,'RoundingMethod','Floor','OverflowAction','Wrap');
        const07p=stage1.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','CONST07P');
        const07p.SimulinkRate=dataRate;
        pirelab.getConstComp(stage1,const07p,CONST07P);


        yX07=stage1.addSignal2('Type',pir_sfixpt_t(WORDLENGTH+TWDL_WORDLENGTH,FRACTIONLENGTH+TWDL_FRACTIONLENGTH),'Name','yX07');
        yX07.SimulinkRate=dataRate;
        vX07=stage1.addSignal2('Type',pir_sfixpt_t(WORDLENGTH+TWDL_WORDLENGTH,FRACTIONLENGTH+TWDL_FRACTIONLENGTH),'Name','vX07');
        vX07.SimulinkRate=dataRate;
        complexMultipy=this.elabComplexMultiply(stage1,WORDLENGTH,FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
        din_re,din_im,const07p,const07p,yX07,vX07);
        pirelab.instantiateNetwork(stage1,complexMultipy,[din_re,din_im,const07p,const07p],...
        [yX07,vX07],'complexMultiply');
        twdlXsampleInput=[din_re,din_im,yX07,vX07,procEnb];
    else
        const0=stage1.addSignal2('Type',pir_sfixpt_t(TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH),'Name','CONST0');
        const0.SimulinkRate=dataRate;
        CONST0=0;
        pirelab.getConstComp(stage1,const0,CONST0);
        twdlXsampleInput=[din_re,din_im,const0,const0,procEnb];
    end
    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','twdlXsample.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='twdlXsample';

    twdlXsample=stage1.addComponent2(...
    'kind','cgireml',...
    'Name','twdlXsample',...
    'InputSignals',[twdlXsampleInput],...
    'OutputSignals',[in2_re,in2_im],...
    'ExternalSynchronousResetSignal',softReset,...
    'EMLFileName','twdlXsample',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{stageNum,TOTALSTAGES,WORDLENGTH,FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);


    twdlXsample.runConcurrencyMaximizer(0);


    softReset_Parent=inputPort(4);
    ButterFlyF=this.elabRADIX2ButterflyF(stage1,blockInfo,stageNum,dataRate,x_re_0,in2_re,x_im_0,in2_im,procEnb,softReset_Parent,x_out,u_out,y_out,v_out,doutVld);

    pirelab.instantiateNetwork(stage1,ButterFlyF,[x_re_0,in2_re,x_im_0,in2_im,procEnb,softReset_Parent],...
    [x_out,u_out,y_out,v_out,doutVld],'ButterflyF');



    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','outputMuxF.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='outputMuxF';

    outMuxF=stage1.addComponent2(...
    'kind','cgireml',...
    'Name','outputMuxF',...
    'InputSignals',[doutVld,x_out,u_out,dOutVld_0,x_re_0,x_im_0,dOutVld_1,x_re_1,x_im_1],...
    'OutputSignals',[dout_re,dout_im,dout_vld,txEOF],...
    'ExternalSynchronousResetSignal',softReset,...
    'EMLFileName','outputMuxF',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{SIGNED,WORDLENGTH,FRACTIONLENGTH,ADDRRANGE,PROCESS_DELAY},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    outMuxF.runConcurrencyMaximizer(0);

end
