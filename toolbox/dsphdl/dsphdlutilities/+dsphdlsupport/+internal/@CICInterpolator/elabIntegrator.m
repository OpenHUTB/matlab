function iSection=elabIntegrator(~,hTopN,blockInfo,slRate,usOut_re,usOut_im,us_vout,internalReset,...
    integOut_re,integOut_im)




    in1=usOut_re;
    in2=usOut_im;
    in3=us_vout;
    in4=internalReset;

    out1=integOut_re;
    out2=integOut_im;


    iSection=pirelab.createNewNetwork(...
    'Network',hTopN,...
    'Name','iSection',...
    'InportNames',{'usOut_re','usOut_im','us_vout','internalReset'},...
    'InportTypes',[in1.Type,in2.Type,in3.Type,in4.Type],...
    'Inportrates',[slRate,slRate,slRate,slRate],...
    'OutportNames',{'integOut_re','integOut_im'},...
    'OutportTypes',[out1.Type,out2.Type]...
    );


    usOut_re=iSection.PirInputSignals(1);
    usOut_im=iSection.PirInputSignals(2);
    us_vout=iSection.PirInputSignals(3);
    internalReset=iSection.PirInputSignals(4);

    integOut_re=iSection.PirOutputSignals(1);
    integOut_im=iSection.PirOutputSignals(2);

    for i=blockInfo.NumSections+1:2*blockInfo.NumSections

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


    pirelab.getDTCComp(iSection,usOut_re,iIn_re(blockInfo.NumSections+1),'Floor','Wrap');
    pirelab.getDTCComp(iSection,usOut_im,iIn_im(blockInfo.NumSections+1),'Floor','Wrap');

    for i=blockInfo.NumSections+1:2*blockInfo.NumSections
        pirelab.getAddComp(iSection,[iIn_re(i),iOut_re(i)],addOut_re(i));
        pirelab.getAddComp(iSection,[iIn_im(i),iOut_im(i)],addOut_im(i));
        pirelab.getIntDelayEnabledResettableComp(iSection,addOut_re(i),iOutreg_re(i),us_vout,internalReset,1);
        pirelab.getIntDelayEnabledResettableComp(iSection,addOut_im(i),iOutreg_im(i),us_vout,internalReset,1);
        pirelab.getDTCComp(iSection,iOutreg_re(i),iOut_re(i),'Floor','Wrap');
        pirelab.getDTCComp(iSection,iOutreg_im(i),iOut_im(i),'Floor','Wrap');
        if~(i==2*blockInfo.NumSections)
            pirelab.getDTCComp(iSection,iOut_re(i),iIn_re(i+1),'Floor','Wrap');
            pirelab.getDTCComp(iSection,iOut_im(i),iIn_im(i+1),'Floor','Wrap');
        end
    end
    pirelab.getDTCComp(iSection,iOut_re(2*blockInfo.NumSections),integOut_re,'Floor','Wrap');
    pirelab.getDTCComp(iSection,iOut_im(2*blockInfo.NumSections),integOut_im,'Floor','Wrap');
end
