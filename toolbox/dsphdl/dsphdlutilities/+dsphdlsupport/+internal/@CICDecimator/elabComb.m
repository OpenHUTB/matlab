function cSection=elabComb(~,hTopN,blockInfo,slRate,dsOut_re,dsOut_im,ds_vout,internalReset,combOut_re,combOut_im,c_vout)




    in1=dsOut_re;
    in2=dsOut_im;
    in3=ds_vout;
    in4=internalReset;

    out1=combOut_re;
    out2=combOut_im;
    out3=c_vout;


    cSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','cSection',...
    'InportNames',{'dsOut_re','dsOut_im','ds_vout','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type,in4.Type],...
    'Inportrates',[slRate,slRate,slRate,slRate],...
    'OutportNames',{'combOut_re','combOut_im','c_vout'},...
    'OutportTypes',[out1.Type,out2.Type,out3.Type]...
    );


    dsOut_re=cSection.PirInputSignals(1);
    dsOut_im=cSection.PirInputSignals(2);
    ds_vout=cSection.PirInputSignals(3);
    internalReset=cSection.PirInputSignals(4);

    combOut_re=cSection.PirOutputSignals(1);
    combOut_im=cSection.PirOutputSignals(2);
    c_vout=cSection.PirOutputSignals(3);

    combOutreg_re=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{2*blockInfo.NumSections}.WordLength,blockInfo.stageDT{2*blockInfo.NumSections}.FractionLength),'combOutreg_re');
    combOutreg_re.SimulinkRate=slRate;
    combOutreg_im=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{2*blockInfo.NumSections}.WordLength,blockInfo.stageDT{2*blockInfo.NumSections}.FractionLength),'combOutreg_im');
    combOutreg_im.SimulinkRate=slRate;


    invalidOut_re=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{2*blockInfo.NumSections}.WordLength,blockInfo.stageDT{2*blockInfo.NumSections}.FractionLength),'invalidOut_re');
    invalidOut_re.SimulinkRate=slRate;
    invalidOut_im=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{2*blockInfo.NumSections}.WordLength,blockInfo.stageDT{2*blockInfo.NumSections}.FractionLength),'invalidOut_im');
    invalidOut_im.SimulinkRate=slRate;

    p=1;
    for i=blockInfo.NumSections+1:2*blockInfo.NumSections

        cIn_re(p)=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['cIn_re',num2str(p)]);
        cIn_re(p).SimulinkRate=slRate;
        cIn_im(p)=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['cIn_im',num2str(p)]);
        cIn_im(p).SimulinkRate=slRate;
        c_vin(p)=cSection.addSignal(c_vout.Type,['cvIn',num2str(p)]);
        c_vin(p).SimulinkRate=slRate;


        cOut_re(p)=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['cOut_re',num2str(p)]);
        cOut_re(p).SimulinkRate=slRate;
        cOut_im(p)=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['cOut_im',num2str(p)]);
        cOut_im(p).SimulinkRate=slRate;


        subOut_re(p)=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength+1,blockInfo.stageDT{i}.FractionLength),['subOut_re',num2str(p)]);
        subOut_re(p).SimulinkRate=slRate;
        subOut_im(p)=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength+1,blockInfo.stageDT{i}.FractionLength),['subOut_im',num2str(p)]);
        subOut_im(p).SimulinkRate=slRate;


        cBuff_re(p)=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['cBuff_re',num2str(p)]);
        cBuff_re(p).SimulinkRate=slRate;
        cBuff_im(p)=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['cBuff_im',num2str(p)]);
        cBuff_im(p).SimulinkRate=slRate;
        cBuff_vout(p)=cSection.addSignal(c_vout.Type,['cBuff_vout',num2str(p)]);
        cBuff_vout(p).SimulinkRate=slRate;


        cDelay_re(p)=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['cDelay_re',num2str(p)]);
        cDelay_re(p).SimulinkRate=slRate;
        cDelay_im(p)=cSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['cDelay_im',num2str(p)]);
        cDelay_im(p).SimulinkRate=slRate;

        p=p+1;
    end %#ok<*AGROW>

    pirelab.getDTCComp(cSection,dsOut_re,cIn_re(1),'Floor','Wrap');
    pirelab.getDTCComp(cSection,dsOut_im,cIn_im(1),'Floor','Wrap');
    pirelab.getWireComp(cSection,ds_vout,c_vin(1));
    for i=1:blockInfo.NumSections
        pirelab.getIntDelayEnabledResettableComp(cSection,cIn_re(i),cDelay_re(i),c_vin(i),internalReset,blockInfo.DifferentialDelay);
        pirelab.getIntDelayEnabledResettableComp(cSection,cIn_im(i),cDelay_im(i),c_vin(i),internalReset,blockInfo.DifferentialDelay);
        pirelab.getSubComp(cSection,[cIn_re(i),cDelay_re(i)],subOut_re(i));
        pirelab.getSubComp(cSection,[cIn_im(i),cDelay_im(i)],subOut_im(i));
        pirelab.getDTCComp(cSection,subOut_re(i),cOut_re(i),'Floor','Wrap');
        pirelab.getDTCComp(cSection,subOut_im(i),cOut_im(i),'Floor','Wrap');
        if~(i==blockInfo.NumSections)
            pirelab.getDTCComp(cSection,cBuff_re(i),cIn_re(i+1),'Floor','Wrap');
            pirelab.getDTCComp(cSection,cBuff_im(i),cIn_im(i+1),'Floor','Wrap');
            pirelab.getWireComp(cSection,cBuff_vout(i),c_vin(i+1));
        end
        pirelab.getIntDelayEnabledResettableComp(cSection,cOut_re(i),cBuff_re(i),1,internalReset,1);
        pirelab.getIntDelayEnabledResettableComp(cSection,cOut_im(i),cBuff_im(i),1,internalReset,1);
        pirelab.getIntDelayEnabledResettableComp(cSection,c_vin(i),cBuff_vout(i),1,internalReset,1);
    end

    pirelab.getIntDelayEnabledResettableComp(cSection,cBuff_vout(blockInfo.NumSections),c_vout,1,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,combOutreg_re,combOut_re,1,internalReset,1);
    pirelab.getIntDelayEnabledResettableComp(cSection,combOutreg_im,combOut_im,1,internalReset,1);

    pirelab.getConstComp(cSection,invalidOut_re,0,'invalidOut_re');
    pirelab.getSwitchComp(cSection,[cBuff_re(blockInfo.NumSections),invalidOut_re],combOutreg_re,cBuff_vout(blockInfo.NumSections),'','==',1);
    pirelab.getConstComp(cSection,invalidOut_im,0,'invalidOut_im');
    pirelab.getSwitchComp(cSection,[cBuff_im(blockInfo.NumSections),invalidOut_im],combOutreg_im,cBuff_vout(blockInfo.NumSections),'','==',1);
end
