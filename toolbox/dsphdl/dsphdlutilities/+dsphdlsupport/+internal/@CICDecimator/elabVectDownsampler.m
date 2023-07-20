function dsSection=elabVectDownsampler(~,hTopN,blockInfo,slRate,integOut_re,integOut_im,i_vout,i_rstout,...
    dsOut_re,dsOut_im,ds_vout)





    in1=integOut_re;
    in2=integOut_im;
    in3=i_vout;
    in4=i_rstout;

    out1=dsOut_re;
    out2=dsOut_im;
    out3=ds_vout;


    dsSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','dsSection',...
    'InportNames',{'integOut_re','integOut_im','i_vout','i_rstout'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type,in4.Type],...
    'Inportrates',[slRate,slRate,slRate,slRate],...
    'OutportNames',{'dsOut_re','dsOut_im','ds_vout'},...
    'OutportTypes',[out1.Type,out2.Type,out3.Type]...
    );


    integOut_re=dsSection.PirInputSignals(1);
    integOut_im=dsSection.PirInputSignals(2);
    i_vout=dsSection.PirInputSignals(3);
    i_rstout=dsSection.PirInputSignals(4);

    dsOut_re=dsSection.PirOutputSignals(1);
    dsOut_im=dsSection.PirOutputSignals(2);
    ds_vout=dsSection.PirOutputSignals(3);

    residueDS=blockInfo.residue;
    vecCountDS=blockInfo.vecCount;

    idx1=blockInfo.index1;
    idx2=blockInfo.index2;
    vecSize=blockInfo.vecsize;
    VecFlag=blockInfo.vecFlag;
    cInputs=blockInfo.numcombinputs;


    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@CICDecimator','cgireml','decimateVect.m'),'r');
    decimateVect=fread(fid,Inf,'char=>char');
    fclose(fid);
    dsSection.addComponent2(...
    'kind','cgireml',...
    'Name','decimateVect',...
    'InputSignals',[integOut_re,integOut_im,i_vout,i_rstout],...
    'OutputSignals',[dsOut_re,dsOut_im,ds_vout],...
    'EMLFileName','decimateVect',...
    'EMLFileBody',decimateVect,...
    'EmlParams',{residueDS,vecCountDS,idx1,idx2,vecSize,VecFlag,cInputs},...
    'EMLFlag_TreatInputIntsAsFixpt',true);
end
