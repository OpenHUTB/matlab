function btf=elabRADIX2ButterflyF(this,topNet,blockInfo,stageNum,dataRate,x_in,in2_re,u_in,in2_im,din_vld,softReset,x_out,u_out,y_out,v_out,doutVld)






    btf=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Radix2ButterlyF',...
    'InportNames',{x_in.Name,in2_re.Name,u_in.Name,in2_im.Name,din_vld.Name,softReset.Name},...
    'InportTypes',[x_in.Type;in2_re.Type;u_in.Type;in2_im.Type;din_vld.Type;softReset.Type],...
    'InportRates',[dataRate;dataRate;dataRate;dataRate;dataRate;dataRate],...
    'OutportNames',{x_out.Name,u_out.Name,y_out.Name,v_out.Name,doutVld.Name},...
    'OutportTypes',[x_out.Type;u_out.Type;y_out.Type;v_out.Type;doutVld.Type]...
    );


    inputPort=btf.PirInputSignals;
    outputPort=btf.PirOutputSignals;


    x_in=inputPort(1);
    in2_re=inputPort(2);
    u_in=inputPort(3);
    in2_im=inputPort(4);
    din_vld=inputPort(5);

    HASRESETPORT=blockInfo.inMode(2);
    if HASRESETPORT
        softReset=inputPort(6);
    else
        softReset='';
    end

    x_out=outputPort(1);
    u_out=outputPort(2);
    y_out=outputPort(3);
    v_out=outputPort(4);
    doutVld=outputPort(5);

    NORMALIZE=blockInfo.Normalize;
    WORDLENGTH=x_in.Type.WordLength;
    FRACTIONLENGTH=x_in.Type.FractionLength;
    OVERFLOWACTION=blockInfo.OverflowAction;
    ROUNDINGMETHOD=blockInfo.RoundingMethod;
    TWDL_WORDLENGTH=blockInfo.TWDL_WORDLENGTH;
    TWDL_FRACTIONLENGTH=-blockInfo.TWDL_FRACTIONLENGTH;


    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities',...
    '+dsphdlsupport','+internal','@AbstractFFT','cgireml','Radix2ButterflyF.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char')';
    fclose(fid);

    desc='Radix2ButterflyF';

    Radix2ButterflyF=btf.addComponent2(...
    'kind','cgireml',...
    'Name','Radix2ButterflyF',...
    'InputSignals',[x_in,in2_re,u_in,in2_im,din_vld],...
    'OutputSignals',[x_out,y_out,u_out,v_out,doutVld],...
    'ExternalSynchronousResetSignal',softReset,...
    'EMLFileName','Radix2ButterflyF',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{stageNum,WORDLENGTH,FRACTIONLENGTH,TWDL_WORDLENGTH,TWDL_FRACTIONLENGTH,OVERFLOWACTION,ROUNDINGMETHOD,NORMALIZE},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'EMLFlag_TreatInputBoolsAsUfix1',false,...
    'BlockComment',desc);

    Radix2ButterflyF.runConcurrencyMaximizer(0);


end
