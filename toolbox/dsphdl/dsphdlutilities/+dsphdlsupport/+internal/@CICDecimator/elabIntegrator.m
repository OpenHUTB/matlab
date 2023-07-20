function iSection=elabIntegrator(~,hTopN,blockInfo,slRate,dataInreg,validInreg,internalReset,...
    integOut_re,integOut_im)




    in1=dataInreg;
    in2=validInreg;
    in3=internalReset;

    out1=integOut_re;
    out2=integOut_im;


    iSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','iSection',...
    'InportNames',{'dataInreg','validInreg','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type],...
    'Inportrates',[slRate,slRate,slRate],...
    'OutportNames',{'integOut_re','integOut_im'},...
    'OutportTypes',[out1.Type,out2.Type]...
    );


    dataInreg=iSection.PirInputSignals(1);
    validInreg=iSection.PirInputSignals(2);
    internalReset=iSection.PirInputSignals(3);

    integOut_re=iSection.PirOutputSignals(1);
    integOut_im=iSection.PirOutputSignals(2);

    for i=1:blockInfo.NumSections

        iIn_re(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['iIn_re',num2str(i)]);
        iIn_re(i).SimulinkRate=slRate;
        iIn_im(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['iIn_im',num2str(i)]);
        iIn_im(i).SimulinkRate=slRate;

        iOut_re(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['iOut_re',num2str(i)]);
        iOut_re(i).SimulinkRate=slRate;
        iOut_im(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength,blockInfo.stageDT{i}.FractionLength),['iOut_im',num2str(i)]);
        iOut_im(i).SimulinkRate=slRate;
        iOutreg_re(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength+1,blockInfo.stageDT{i}.FractionLength),['iOutreg_re',num2str(i)]);
        iOutreg_re(i).SimulinkRate=slRate;
        iOutreg_im(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength+1,blockInfo.stageDT{i}.FractionLength),['iOutreg_im',num2str(i)]);
        iOutreg_im(i).SimulinkRate=slRate;

        addOut_re(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength+1,blockInfo.stageDT{i}.FractionLength),['addOut_re',num2str(i)]);
        addOut_re(i).SimulinkRate=slRate;
        addOut_im(i)=iSection.addSignal(pir_sfixpt_t(blockInfo.stageDT{i}.WordLength+1,blockInfo.stageDT{i}.FractionLength),['addOut_im',num2str(i)]);
        addOut_im(i).SimulinkRate=slRate;
    end %#ok<*AGROW>

    dataInreg_cast=iSection.addSignal2('Type',pir_complex_t(pir_sfixpt_t(dataInreg.Type.BaseType.WordLength,dataInreg.Type.BaseType.FractionLength)),'Name','dataInreg_cast');%#ok<*AGROW>
    dataInreg_cast.SimulinkRate=slRate;
    din_re=iSection.addSignal(pir_sfixpt_t(dataInreg.Type.BaseType.WordLength,dataInreg.Type.BaseType.FractionLength),'din_re');
    din_re.SimulinkRate=slRate;
    din_im=iSection.addSignal(pir_sfixpt_t(dataInreg.Type.BaseType.WordLength,dataInreg.Type.BaseType.FractionLength),'din_im');
    din_im.SimulinkRate=slRate;

    pirelab.getDTCComp(iSection,dataInreg,dataInreg_cast);
    pirelab.getComplex2RealImag(iSection,dataInreg_cast,[din_re,din_im],'real and img');
    pirelab.getDTCComp(iSection,din_re,iIn_re(1),'Floor','Wrap');
    pirelab.getDTCComp(iSection,din_im,iIn_im(1),'Floor','Wrap');

    for i=1:blockInfo.NumSections
        pirelab.getAddComp(iSection,[iIn_re(i),iOut_re(i)],addOut_re(i));
        pirelab.getAddComp(iSection,[iIn_im(i),iOut_im(i)],addOut_im(i));
        pirelab.getIntDelayEnabledResettableComp(iSection,addOut_re(i),iOutreg_re(i),validInreg,internalReset,1);
        pirelab.getIntDelayEnabledResettableComp(iSection,addOut_im(i),iOutreg_im(i),validInreg,internalReset,1);
        pirelab.getDTCComp(iSection,iOutreg_re(i),iOut_re(i),'Floor','Wrap');
        pirelab.getDTCComp(iSection,iOutreg_im(i),iOut_im(i),'Floor','Wrap');
        if~(i==blockInfo.NumSections)
            pirelab.getDTCComp(iSection,iOut_re(i),iIn_re(i+1),'Floor','Wrap');
            pirelab.getDTCComp(iSection,iOut_im(i),iIn_im(i+1),'Floor','Wrap');
        end
    end
    pirelab.getDTCComp(iSection,iOut_re(blockInfo.NumSections),integOut_re,'Floor','Wrap');
    pirelab.getDTCComp(iSection,iOut_im(blockInfo.NumSections),integOut_im,'Floor','Wrap');
end
