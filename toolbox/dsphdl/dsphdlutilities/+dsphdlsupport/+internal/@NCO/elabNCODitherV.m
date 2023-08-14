function ditherNet=elabNCODitherV(~,topNet,blockInfo,dataRate,dim)



    accWL=blockInfo.AccuWL;
    accType=pir_sfixpt_t(accWL,0);
    TotalditherBits=blockInfo.DitherBits*dim;
    ditherBits=blockInfo.DitherBits;

    if(dim==1)
        outporttypes=accType;
    else
        outporttypes=pirelab.createPirArrayType(accType,dim);
    end



    u_ditherType=pir_ufixpt_t(blockInfo.DitherBits,0);
    s_ditherType=pir_sfixpt_t(blockInfo.DitherBits,0);
    s_outputType=pir_sfixpt_t(accWL,0);
    u_outputType=pir_ufixpt_t(accWL,0);


    ditherNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DitherGen',...
    'InportNames',{'validIn'},...
    'InportTypes',pir_boolean_t,...
    'OutportNames',{'dither'},...
    'OutportTypes',outporttypes...
    );



    dithervalue=ditherNet.PirOutputSignals(1);

    validIn=ditherNet.PirInputSignals(1);





    ufix1Type=pir_ufixpt_t(1,0);

    dregType=pir_ufixpt_t(19,0);
    dregsfType=pir_ufixpt_t(18,0);
    pn_reg=ditherNet.addSignal(dregType,'pn_reg');
    pn_reg.SimulinkRate=blockInfo.SimulinkRate;


    bit18(TotalditherBits)=ditherNet.addSignal(ufix1Type,['bit18_',num2str(TotalditherBits)]);
    bit17(TotalditherBits)=ditherNet.addSignal(ufix1Type,['bit17_',num2str(TotalditherBits)]);
    bit14(TotalditherBits)=ditherNet.addSignal(ufix1Type,['bit14_',num2str(TotalditherBits)]);
    bit0(TotalditherBits)=ditherNet.addSignal(ufix1Type,['bit0_',num2str(TotalditherBits)]);
    xorout(TotalditherBits)=ditherNet.addSignal(ufix1Type,['xorout',num2str(TotalditherBits)]);
    pn_newvalue(TotalditherBits+1)=ditherNet.addSignal(dregType,['pn_newvalue',num2str(TotalditherBits+1)]);
    pn_newvaluesf(TotalditherBits)=ditherNet.addSignal(dregsfType,['pn_newvaluesf',num2str(TotalditherBits)]);



    for k=1:TotalditherBits

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
    pn_newvalue(TotalditherBits+1)=ditherNet.addSignal(dregType,['pn_newvalue',num2str(TotalditherBits)]);
    pn_newvalue(TotalditherBits+1).SimulinkRate=blockInfo.SimulinkRate;


    regcomp=pirelab.getUnitDelayEnabledComp(ditherNet,pn_newvalue(TotalditherBits+1),pn_reg,validIn,'PNgenRegister',1);
    regcomp.addComment('PNgen register');
    pn_reg.SimulinkRate=dataRate;
    pirelab.getDTCComp(ditherNet,pn_reg,pn_newvalue(1),'floor','wrap');

    pnout=[];
    for k=1:TotalditherBits



        pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),bit18(k),18,18);
        pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),bit17(k),17,17);
        pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),bit14(k),14,14);
        pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),bit0(k),0,0);



        comp=pirelab.getLogicComp(ditherNet,[bit18(k),bit17(k),bit14(k),bit0(k)],xorout(k),'xor');
        comp.addComment(['Stage',num2str(k),': Compute register output and shift']);


        pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),pn_newvaluesf(k),18,1);
        pirelab.getBitConcatComp(ditherNet,[xorout(k),pn_newvaluesf(k)],pn_newvalue(k+1));

        pnout=[pnout,bit0(k)];%#ok<*AGROW>

    end

    for i=0:dim-1
        dither_element(i+1)=ditherNet.addSignal(u_ditherType,'dither_element');
        dither_element(i+1).SimulinkRate=dataRate;
        dither_temp(i+1)=ditherNet.addSignal(s_ditherType,'dither_temp');
        dither_temp(i+1).SimulinkRate=dataRate;
        s_output_temp(i+1)=ditherNet.addSignal(s_outputType,'s_output_temp');
        s_output_temp(i+1).SimulinkRate=dataRate;
        u_output_temp(i+1)=ditherNet.addSignal(u_outputType,'u_output_temp');
        u_output_temp(i+1).SimulinkRate=dataRate;
        output_reg(i+1)=ditherNet.addSignal(s_outputType,'output_reg');
        output_reg(i+1).SimulinkRate=dataRate;


        pirelab.getBitConcatComp(ditherNet,pnout(i*ditherBits+1:(i+1)*ditherBits),dither_element(i+1));

        pirelab.getDTCComp(ditherNet,dither_element(i+1),u_output_temp(i+1),'floor','wrap');
        pirelab.getDTCComp(ditherNet,u_output_temp(i+1),s_output_temp(i+1),'floor','wrap');
        pirelab.getIntDelayComp(ditherNet,s_output_temp(i+1),output_reg(i+1),3,0);
    end




    comp=pirelab.getMuxComp(ditherNet,output_reg,dithervalue);
    comp.addComment('Dither Output');
    dithervalue.SimulinkRate=dataRate;

end
