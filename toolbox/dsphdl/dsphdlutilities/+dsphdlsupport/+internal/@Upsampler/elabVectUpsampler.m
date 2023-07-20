function usSection=elabVectUpsampler(~,hTopN,blockInfo,slRate,dataInus_re,dataInus_im,validInus,internalReset,...
    usOut_re,usOut_im,us_vout)




    in1=dataInus_re;
    in2=dataInus_im;
    in3=validInus;
    in4=internalReset;

    out1=usOut_re;
    out2=usOut_im;
    out3=us_vout;


    usSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','usSection',...
    'InportNames',{'dataInus_re','dataInus_im','validInus','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type,in4.Type],...
    'Inportrates',[slRate,slRate,slRate,slRate],...
    'OutportNames',{'usOut_re','usOut_im','us_vout'},...
    'OutportTypes',[out1.Type,out2.Type,out3.Type]...
    );


    dataInus_re=usSection.PirInputSignals(1);
    dataInus_im=usSection.PirInputSignals(2);
    validInus=usSection.PirInputSignals(3);
    if blockInfo.inMode(2)
        internalReset=usSection.PirInputSignals(4);
    else
        internalReset='';
    end


    usOut_re=usSection.PirOutputSignals(1);
    usOut_im=usSection.PirOutputSignals(2);
    us_vout=usSection.PirOutputSignals(3);

    if(blockInfo.NumCycles<blockInfo.UpsampleFactor&&blockInfo.NumCycles~=1)&&blockInfo.vecsize==1
        dsOutSize=blockInfo.R2;
    else
        dsOutSize=blockInfo.R1;
    end
    residueVect=blockInfo.residueVect;
    vecsize=blockInfo.vecsize;
    upsampleFact=blockInfo.UpsampleFactor;
    sampleOffset=blockInfo.SampleOffset;
    stagevecSize=blockInfo.stageVecsize;
    numCycles=blockInfo.NumCycles;


    fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
    '@Upsampler','cgireml','upSamplerVect.m'),'r');
    upSamplerVect=fread(fid,Inf,'char=>char');
    fclose(fid);
    usSection.addComponent2(...
    'kind','cgireml',...
    'Name','upSamplerVect',...
    'InputSignals',[dataInus_re,dataInus_im,validInus],...
    'OutputSignals',[usOut_re,usOut_im,us_vout],...
    'EMLFileName','upSamplerVect',...
    'EMLFileBody',upSamplerVect,...
    'EmlParams',{dsOutSize,residueVect,vecsize,upsampleFact,sampleOffset,stagevecSize,numCycles},...
    'ExternalSynchronousResetSignal',internalReset,...
    'EMLFlag_TreatInputIntsAsFixpt',true);
end