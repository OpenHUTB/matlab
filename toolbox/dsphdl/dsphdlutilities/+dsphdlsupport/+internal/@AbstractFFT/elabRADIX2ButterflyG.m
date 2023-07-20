function btf=elabRADIX2ButterflyG(this,topNet,TOTALSTAGES,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,blockInfo,dataRate,...
    stageIn,realIn_vld,twiddle_re,twiddle_im,x_u_in,y_v_in,v_y_in,extended_dvld,softReset,stageOut,x_out,u_out,y_out,v_out,realOut_dvld,doutVld)





    TWDL_WORDLENGTH=blockInfo.TWDL_WORDLENGTH;
    TWDL_FRACTIONLENGTH=-blockInfo.TWDL_FRACTIONLENGTH;

    btf=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Radix2ButterflyG',...
    'InportNames',{stageIn.Name,realIn_vld.Name,twiddle_re.Name,twiddle_im.Name,x_u_in.Name,y_v_in.Name,v_y_in.Name,extended_dvld.Name,softReset.Name},...
    'InportTypes',[stageIn.Type;realIn_vld.Type;twiddle_re.Type;twiddle_im.Type;x_u_in.Type;y_v_in.Type;v_y_in.Type;extended_dvld.Type;softReset.Type],...
    'InportRates',[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate;dataRate],...
    'OutportNames',{stageOut.Name,x_out.Name,u_out.Name,y_out.Name,v_out.Name,realOut_dvld.Name,doutVld.Name},...
    'OutportTypes',[stageOut.Type;x_out.Type;u_out.Type;y_out.Type;v_out.Type;realOut_dvld.Type;doutVld.Type]...
    );


    inputPort=btf.PirInputSignals;
    outputPort=btf.PirOutputSignals;

    stageIn=inputPort(1);
    realIn_vld=inputPort(2);
    twiddle_re=inputPort(3);
    twiddle_im=inputPort(4);
    x_u_in=inputPort(5);
    y_v_in=inputPort(6);
    v_y_in=inputPort(7);
    extended_dvld=inputPort(8);

    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        softReset=inputPort(9);
    else
        softReset='';
    end

    stageOut=outputPort(1);
    x_out=outputPort(2);
    u_out=outputPort(3);
    y_out=outputPort(4);
    v_out=outputPort(5);
    realOut_dvld=outputPort(6);
    doutVld=outputPort(7);


    outType=pir_sfixpt_t(DATA_WORDLENGTH+TWDL_WORDLENGTH,DATA_FRACTIONLENGTH+TWDL_FRACTIONLENGTH);
    multRes1=btf.addSignal2('Type',outType,'Name','multRes1');
    multRes1.SimulinkRate=dataRate;
    multRes2=btf.addSignal2('Type',outType,'Name','multRes2');
    multRes2.SimulinkRate=dataRate;



    complexMultipy=this.elabComplexMultiply(btf,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,dataRate,...
    y_v_in,v_y_in,twiddle_re,twiddle_im,multRes1,multRes2);
    pirelab.instantiateNetwork(btf,complexMultipy,[y_v_in,v_y_in,twiddle_re,twiddle_im],...
    [multRes1,multRes2],'complexMultiply');


    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','Radix2ButterflyG.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Radix2ButterflyG';

    Radix2ButterflyG=btf.addComponent2(...
    'kind','cgireml',...
    'Name','Radix2ButterflyG',...
    'InputSignals',[stageIn,realIn_vld,x_u_in,multRes1,multRes2,extended_dvld],...
    'OutputSignals',[stageOut,x_out,u_out,y_out,v_out,realOut_dvld,doutVld],...
    'ExternalSynchronousResetSignal',softReset,...
    'EMLFileName','Radix2ButterflyG',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{TOTALSTAGES,DATA_WORDLENGTH,DATA_FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    Radix2ButterflyG.runConcurrencyMaximizer(0);

end
