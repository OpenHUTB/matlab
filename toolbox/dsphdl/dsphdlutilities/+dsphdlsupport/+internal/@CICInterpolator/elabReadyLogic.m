function rdySection=elabReadyLogic(~,hTopN,blockInfo,slRate,dataInreg,validInreg,internalReset,upsampleVal,...
    rdyout_re,rdyout_im,rdy_valid)




    in1=dataInreg;
    in2=validInreg;
    in3=internalReset;
    in4=upsampleVal;

    out1=rdyout_re;
    out2=rdyout_im;
    out3=rdy_valid;


    rdySection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','rdySection',...
    'InportNames',{'dataInreg','validInreg','internalReset','upsampleVal'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type,in4.Type],...
    'Inportrates',[slRate,slRate,slRate,slRate],...
    'OutportNames',{'rdyout_re','rdyout_im','rdy_valid'},...
    'OutportTypes',[out1.Type,out2.Type,out3.Type]...
    );


    dataInreg=rdySection.PirInputSignals(1);
    validInreg=rdySection.PirInputSignals(2);
    internalReset=rdySection.PirInputSignals(3);
    upsampleVal=rdySection.PirInputSignals(4);

    rdyout_re=rdySection.PirOutputSignals(1);
    rdyout_im=rdySection.PirOutputSignals(2);
    rdy_valid=rdySection.PirOutputSignals(3);

    rdyIn_re=rdySection.addSignal(pir_sfixpt_t(blockInfo.stageDT{1}.WordLength,blockInfo.stageDT{1}.FractionLength),'rdyIn_re');
    rdyIn_re.SimulinkRate=slRate;
    rdyIn_im=rdySection.addSignal(pir_sfixpt_t(blockInfo.stageDT{1}.WordLength,blockInfo.stageDT{1}.FractionLength),'rdyIn_im');
    rdyIn_im.SimulinkRate=slRate;

    dataInreg_cast=rdySection.addSignal2('Type',pir_complex_t(pir_sfixpt_t(dataInreg.Type.BaseType.WordLength,dataInreg.Type.BaseType.FractionLength)),'Name','dataInreg_cast');%#ok<*AGROW>
    dataInreg_cast.SimulinkRate=slRate;
    din_re=rdySection.addSignal(pir_sfixpt_t(dataInreg.Type.BaseType.WordLength,dataInreg.Type.BaseType.FractionLength),'din_re');
    din_re.SimulinkRate=slRate;
    din_im=rdySection.addSignal(pir_sfixpt_t(dataInreg.Type.BaseType.WordLength,dataInreg.Type.BaseType.FractionLength),'din_im');
    din_im.SimulinkRate=slRate;

    pirelab.getDTCComp(rdySection,dataInreg,dataInreg_cast);
    pirelab.getComplex2RealImag(rdySection,dataInreg_cast,[din_re,din_im],'real and img');
    pirelab.getDTCComp(rdySection,din_re,rdyIn_re,'Floor','Wrap');
    pirelab.getDTCComp(rdySection,din_im,rdyIn_im,'Floor','Wrap');

    if(blockInfo.MinCycles==1)&&~blockInfo.inMode(2)
        pirelab.getWireComp(rdySection,rdyIn_re,rdyout_re);
        pirelab.getWireComp(rdySection,rdyIn_im,rdyout_im);
        pirelab.getWireComp(rdySection,validInreg,rdy_valid);
    else

        maxInterpFact=blockInfo.InterpolationFactor;
        varFlag=blockInfo.inMode(2);
        fid=fopen(fullfile(matlabroot,'toolbox','dsphdl','dsphdlutilities','+dsphdlsupport','+internal',...
        '@CICInterpolator','cgireml','cicReadyData.m'),'r');
        cicReadyData=fread(fid,Inf,'char=>char');
        fclose(fid);
        rdySection.addComponent2(...
        'kind','cgireml',...
        'Name','cicReadyData',...
        'InputSignals',[rdyIn_re,rdyIn_im,validInreg,upsampleVal,internalReset],...
        'OutputSignals',[rdyout_re,rdyout_im,rdy_valid],...
        'EMLFileName','cicReadyData',...
        'EMLFileBody',cicReadyData,...
        'EmlParams',{maxInterpFact,varFlag},...
        'EMLFlag_TreatInputIntsAsFixpt',true);
    end
end
