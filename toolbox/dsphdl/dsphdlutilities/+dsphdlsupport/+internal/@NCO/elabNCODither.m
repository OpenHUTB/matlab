function ditherNet=elabNCODither(~,topNet,blockInfo,dataRate)




    ditherBits=blockInfo.DitherBits;

    ditherType=pir_ufixpt_t(ditherBits,0);



    ditherNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DitherGen',...
    'InportNames',{'validIn'},...
    'InportTypes',pir_boolean_t,...
    'OutportNames',{'dither'},...
    'OutportTypes',ditherType...
    );



    dithervalue=ditherNet.PirOutputSignals(1);

    validIn=ditherNet.PirInputSignals(1);





    ufix1Type=pir_ufixpt_t(1,0);

    dregType=pir_ufixpt_t(19,0);
    dregsfType=pir_ufixpt_t(18,0);
    pn_reg=ditherNet.addSignal(dregType,'pn_reg');
    pn_reg.SimulinkRate=blockInfo.SimulinkRate;


    bit18(ditherBits)=ditherNet.addSignal(ufix1Type,['bit18_',num2str(ditherBits)]);
    bit17(ditherBits)=ditherNet.addSignal(ufix1Type,['bit17_',num2str(ditherBits)]);
    bit14(ditherBits)=ditherNet.addSignal(ufix1Type,['bit14_',num2str(ditherBits)]);
    bit0(ditherBits)=ditherNet.addSignal(ufix1Type,['bit0_',num2str(ditherBits)]);
    xorout(ditherBits)=ditherNet.addSignal(ufix1Type,['xorout',num2str(ditherBits)]);
    pn_newvalue(ditherBits+1)=ditherNet.addSignal(dregType,['pn_newvalue',num2str(ditherBits+1)]);
    pn_newvaluesf(ditherBits)=ditherNet.addSignal(dregsfType,['pn_newvaluesf',num2str(ditherBits)]);



    for k=1:ditherBits

        bit18(k)=ditherNet.addSignal(ufix1Type,['bit18_',num2str(k-1)]);
        bit18(k).SimulinkRate=blockInfo.SimulinkRate;
        bit17(k)=ditherNet.addSignal(ufix1Type,['bit17_',num2str(k-1)]);
        bit17(k).SimulinkRate=blockInfo.SimulinkRate;
        bit14(k)=ditherNet.addSignal(ufix1Type,['bit14_',num2str(k-1)]);
        bit14(k).SimulinkRate=blockInfo.SimulinkRate;
        bit0(k)=ditherNet.addSignal(ufix1Type,['bit0_',num2str(k-1)]);
        bit0(k).SimulinkRate=blockInfo.SimulinkRate;
        xorout(k)=ditherNet.addSignal(ufix1Type,['xorout',num2str(k-1)]);
        xorout(k).SimulinkRate=blockInfo.SimulinkRate;
        pn_newvalue(k)=ditherNet.addSignal(dregType,['pn_newvalue',num2str(k-1)]);
        pn_newvalue(k).SimulinkRate=blockInfo.SimulinkRate;
        pn_newvaluesf(k)=ditherNet.addSignal(dregsfType,['pn_newvaluesf',num2str(k-1)]);
        pn_newvaluesf(k).SimulinkRate=blockInfo.SimulinkRate;
    end
    pn_newvalue(ditherBits+1)=ditherNet.addSignal(dregType,['pn_newvalue',num2str(ditherBits)]);
    pn_newvalue(ditherBits+1).SimulinkRate=blockInfo.SimulinkRate;


    regcomp=pirelab.getUnitDelayEnabledComp(ditherNet,pn_newvalue(ditherBits+1),pn_reg,validIn,'PNgenRegister',1);
    regcomp.addComment('PNgen register');
    pn_reg.SimulinkRate=dataRate;
    pirelab.getDTCComp(ditherNet,pn_reg,pn_newvalue(1),'floor','wrap');

    pnout=[];
    for k=1:ditherBits



        pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),bit18(k),18,18);
        pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),bit17(k),17,17);
        pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),bit14(k),14,14);
        pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),bit0(k),0,0);



        comp=pirelab.getLogicComp(ditherNet,[bit18(k),bit17(k),bit14(k),bit0(k)],xorout(k),'xor');
        comp.addComment(['Stage',num2str(k),': Compute register output and shift']);


        pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),pn_newvaluesf(k),18,1);
        pirelab.getBitConcatComp(ditherNet,[xorout(k),pn_newvaluesf(k)],pn_newvalue(k+1));

        pnout=[pnout,bit0(k)];

    end



    comp=pirelab.getBitConcatComp(ditherNet,pnout,dithervalue);
    comp.addComment('Dither Output');
    dithervalue.SimulinkRate=dataRate;

end
