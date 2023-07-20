function bSection=elabBuffer(~,hTopN,blockInfo,slRate,usOut1_re,usOut1_im,us_vout1,internalReset,usOut_re,usOut_im,us_vout)




    in1=usOut1_re;
    in2=usOut1_im;
    in3=us_vout1;
    in4=internalReset;

    out1=usOut_re;
    out2=usOut_im;
    out3=us_vout;


    bSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','bSection',...
    'InportNames',{'usOut1_re','usOut1_im','us_vout1','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type,in4.Type],...
    'Inportrates',[slRate,slRate,slRate,slRate],...
    'OutportNames',{'usOut_re','usOut_im','us_vout'},...
    'OutportTypes',[out1.Type,out2.Type,out3.Type]...
    );


    usOut1_re=bSection.PirInputSignals(1);
    usOut1_im=bSection.PirInputSignals(2);
    us_vout1=bSection.PirInputSignals(3);
    if blockInfo.inMode(2)
        internalReset=bSection.PirInputSignals(4);
    else
        internalReset='';
    end


    usOut_re=bSection.PirOutputSignals(1);
    usOut_im=bSection.PirOutputSignals(2);
    us_vout=bSection.PirOutputSignals(3);

    sampleOffset=blockInfo.SampleOffset;
    if(blockInfo.NumCycles<blockInfo.UpsampleFactor||blockInfo.vecsize>1)
        if blockInfo.vecsize==1
            outvecsize1=blockInfo.R2;
        else
            outvecsize1=blockInfo.R1;
        end

        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@Upsampler','cgireml','bufferSectionVecOut.m'),'r');
        bufferSectionVecOut=fread(fid,Inf,'char=>char');
        fclose(fid);
        bSection.addComponent2(...
        'kind','cgireml',...
        'Name','bufferSectionVecOut',...
        'InputSignals',[usOut1_re,usOut1_im,us_vout1],...
        'OutputSignals',[usOut_re,usOut_im,us_vout],...
        'EMLFileName','bufferSectionVecOut',...
        'EMLFileBody',bufferSectionVecOut,...
        'EmlParams',{sampleOffset,outvecsize1},...
        'ExternalSynchronousResetSignal',internalReset,...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    else

        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@Upsampler','cgireml','bufferSection.m'),'r');
        bufferSection=fread(fid,Inf,'char=>char');
        fclose(fid);
        bSection.addComponent2(...
        'kind','cgireml',...
        'Name','bufferSection',...
        'InputSignals',[usOut1_re,usOut1_im,us_vout1],...
        'OutputSignals',[usOut_re,usOut_im,us_vout],...
        'EMLFileName','bufferSection',...
        'EMLFileBody',bufferSection,...
        'EmlParams',{sampleOffset},...
        'ExternalSynchronousResetSignal',internalReset,...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    end