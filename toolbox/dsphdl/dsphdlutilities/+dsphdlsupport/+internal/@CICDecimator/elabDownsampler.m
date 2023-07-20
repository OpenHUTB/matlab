function dsSection=elabDownsampler(~,hTopN,blockInfo,slRate,integOut_re,integOut_im,validInreg,downsampleVal,i_rstout,...
    dsOut_re,dsOut_im,ds_vout)




    in1=integOut_re;
    in2=integOut_im;
    in3=validInreg;
    in4=downsampleVal;
    in5=i_rstout;

    out1=dsOut_re;
    out2=dsOut_im;
    out3=ds_vout;


    dsSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','dsSection',...
    'InportNames',{'integOut_re','integOut_im','validInreg','downsampleVal','i_rstout'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type,in4.Type,in5.Type],...
    'Inportrates',[slRate,slRate,slRate,slRate,slRate],...
    'OutportNames',{'dsOut_re','dsOut_im','ds_vout'},...
    'OutportTypes',[out1.Type,out2.Type,out3.Type]...
    );


    integOut_re=dsSection.PirInputSignals(1);
    integOut_im=dsSection.PirInputSignals(2);
    validInreg=dsSection.PirInputSignals(3);
    downsampleVal=dsSection.PirInputSignals(4);
    i_rstout=dsSection.PirInputSignals(5);

    dsOut_re=dsSection.PirOutputSignals(1);
    dsOut_im=dsSection.PirOutputSignals(2);
    ds_vout=dsSection.PirOutputSignals(3);

    maxDecimFact=blockInfo.DecimationFactor;


    varFlag=blockInfo.inMode(2);
    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@CICDecimator','cgireml','downSampler.m'),'r');
    downSampler=fread(fid,Inf,'char=>char');
    fclose(fid);
    dsSection.addComponent2(...
    'kind','cgireml',...
    'Name','downSampler',...
    'InputSignals',[integOut_re,integOut_im,validInreg,downsampleVal,i_rstout],...
    'OutputSignals',[dsOut_re,dsOut_im,ds_vout],...
    'EMLFileName','downSampler',...
    'EMLFileBody',downSampler,...
    'EmlParams',{maxDecimFact,varFlag},...
    'EMLFlag_TreatInputIntsAsFixpt',true);
end
