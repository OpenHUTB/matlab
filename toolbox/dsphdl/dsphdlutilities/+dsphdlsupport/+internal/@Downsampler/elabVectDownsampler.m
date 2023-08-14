function dsSection=elabVectDownsampler(~,hTopN,blockInfo,slRate,dataInreg,validInreg,internalReset,...
    dsOut_re,dsOut_im,ds_vout)





    in1=dataInreg;
    in2=validInreg;
    in3=internalReset;

    out1=dsOut_re;
    out2=dsOut_im;
    out3=ds_vout;


    dsSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','dsSection',...
    'InportNames',{'dataInreg','validInreg','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type],...
    'Inportrates',[slRate,slRate,slRate],...
    'OutportNames',{'dsOut_re','dsOut_im','ds_vout'},...
    'OutportTypes',[out1.Type,out2.Type,out3.Type]...
    );


    dataInreg=dsSection.PirInputSignals(1);
    validInreg=dsSection.PirInputSignals(2);
    if blockInfo.inMode(2)
        internalReset=dsSection.PirInputSignals(3);
    else
        internalReset='';
    end
    dsOut_re=dsSection.PirOutputSignals(1);
    dsOut_im=dsSection.PirOutputSignals(2);
    ds_vout=dsSection.PirOutputSignals(3);

    inS=blockInfo.issigned;
    inWL=blockInfo.dlen;
    inFL=blockInfo.flen;
    PVType=pir_fixpt_t(inS,inWL,inFL);

    for i=1:blockInfo.vecsize
        dataInreg_cast(i)=dsSection.addSignal2('Type',pir_complex_t(PVType),'Name','dataInreg_cast');%#ok<*AGROW>
        dataInreg_cast(i).SimulinkRate=slRate;
        din_re(i)=dsSection.addSignal(PVType,'din_re');
        din_re(i).SimulinkRate=slRate;
        din_im(i)=dsSection.addSignal(PVType,'din_im');
        din_im(i).SimulinkRate=slRate;
        dsIn_re(i)=dsSection.addSignal(PVType,'dsIn_re');
        dsIn_re(i).SimulinkRate=slRate;
        dsIn_im(i)=dsSection.addSignal(PVType,'dsIn_im');
        dsIn_im(i).SimulinkRate=slRate;
        pirelab.getDTCComp(dsSection,dataInreg.split.PirOutputSignals(i),dataInreg_cast(i));
        pirelab.getComplex2RealImag(dsSection,dataInreg_cast(i),[din_re(i),din_im(i)],'real and img');
        pirelab.getDTCComp(dsSection,din_re(i),dsIn_re(i),'Floor','Wrap');
        pirelab.getDTCComp(dsSection,din_im(i),dsIn_im(i),'Floor','Wrap');
    end

    pVType3=pirelab.getPirVectorType(PVType,blockInfo.vecsize);
    dataIn_re=dsSection.addSignal(pVType3,'dataIn_re');
    dataIn_re.SimulinkRate=slRate;
    dataIn_im=dsSection.addSignal(pVType3,'dataIn_im');
    dataIn_im.SimulinkRate=slRate;
    dsOut1_re=dsSection.addSignal(pVType3,'dsOut1_re');
    dsOut1_re.SimulinkRate=slRate;
    dsOut1_im=dsSection.addSignal(pVType3,'dsOut1_im');
    dsOut1_im.SimulinkRate=slRate;
    pirelab.getMuxComp(dsSection,din_re,dataIn_re);
    pirelab.getMuxComp(dsSection,din_im,dataIn_im);

    residueDS=blockInfo.residue;
    intoffDS=blockInfo.intOff;
    vecCountDS=blockInfo.vecCount;
    idx=blockInfo.index;
    vecSize=blockInfo.vecsize;
    VecFlag=blockInfo.vecFlag;
    numInputs=blockInfo.numinputs;
    dsFact=blockInfo.DownsampleFactor;

    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@Downsampler','cgireml','dsVect.m'),'r');
    dsVect=fread(fid,Inf,'char=>char');
    fclose(fid);
    dsSection.addComponent2(...
    'kind','cgireml',...
    'Name','dsVect',...
    'InputSignals',[dataIn_re,dataIn_im,validInreg],...
    'OutputSignals',[dsOut_re,dsOut_im,ds_vout],...
    'EMLFileName','dsVect',...
    'EMLFileBody',dsVect,...
    'EmlParams',{dsFact,residueDS,intoffDS,vecCountDS,idx,vecSize,VecFlag,numInputs},...
    'ExternalSynchronousResetSignal',internalReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true);
end