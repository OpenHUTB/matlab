function ditherNet=elaborateNCODither(~,topNet,blockInfo,dataRate)



    ditherBits=blockInfo.DitherBits;

    ditherType=pir_ufixpt_t(ditherBits,0);



    ditherNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DitherGen',...
    'OutportNames',{'dither'},...
    'OutportTypes',ditherType...
    );



    dithervalue=ditherNet.PirOutputSignals(1);

    idxPoly=length(blockInfo.polybitpattern)-strfind(blockInfo.polybitpattern,'1');

    ufix1Type=pir_ufixpt_t(1,0);

    dregType=pir_ufixpt_t(idxPoly(1),0);
    dregsfType=pir_ufixpt_t(idxPoly(1)-1,0);
    pn_reg=ditherNet.addSignal(dregType,'pn_reg');
    pn_reg.SimulinkRate=blockInfo.SimulinkRate;

    lenIdxPoly=length(idxPoly);

    xorout(ditherBits)=ditherNet.addSignal(ufix1Type,['xorout',num2str(ditherBits)]);
    pn_newvalue(ditherBits+1)=ditherNet.addSignal(dregType,['pn_newvalue',num2str(ditherBits+1)]);
    pn_newvaluesf(ditherBits)=ditherNet.addSignal(dregsfType,['pn_newvaluesf',num2str(ditherBits)]);



    for bitIdx=2:lenIdxPoly
        for k=1:ditherBits

            bit(bitIdx-1,k)=ditherNet.addSignal(ufix1Type,['bit',num2str(idxPoly(bitIdx)),'_',num2str(k-1)]);
            bit(bitIdx-1,k).SimulinkRate=blockInfo.SimulinkRate;
        end
    end

    for k=1:ditherBits
        xorout(k)=ditherNet.addSignal(ufix1Type,['xorout',num2str(k-1)]);
        xorout(k).SimulinkRate=blockInfo.SimulinkRate;
        pn_newvalue(k)=ditherNet.addSignal(dregType,['pn_newvalue',num2str(k-1)]);
        pn_newvalue(k).SimulinkRate=blockInfo.SimulinkRate;
        pn_newvaluesf(k)=ditherNet.addSignal(dregsfType,['pn_newvaluesf',num2str(k-1)]);
        pn_newvaluesf(k).SimulinkRate=blockInfo.SimulinkRate;
    end
    pn_newvalue(ditherBits+1)=ditherNet.addSignal(dregType,['pn_newvalue',num2str(ditherBits)]);
    pn_newvalue(ditherBits+1).SimulinkRate=blockInfo.SimulinkRate;


    regcomp=pirelab.getUnitDelayComp(ditherNet,pn_newvalue(ditherBits+1),pn_reg,'PNgenRegister',1);
    regcomp.addComment('PNgen register');
    pn_reg.SimulinkRate=dataRate;
    pirelab.getDTCComp(ditherNet,pn_reg,pn_newvalue(1),'floor','wrap');

    pnout=[];

    for k=1:ditherBits

        for bitIdx=2:lenIdxPoly
            pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),bit(bitIdx-1,k),idxPoly(bitIdx),idxPoly(bitIdx));

            bitToXOr(bitIdx-1,k)=ditherNet.addSignal(ufix1Type,['bitToxor',num2str(k-1)]);
            bitToXOr(bitIdx-1,k).SimulinkRate=blockInfo.SimulinkRate;

            bitToXOr(bitIdx-1,k)=bit(bitIdx-1,k);

        end


        comp=pirelab.getLogicComp(ditherNet,[bitToXOr(:,k)],xorout(k),'xor');
        comp.addComment(['Stage',num2str(k),': Compute register output and shift']);


        pirelab.getBitSliceComp(ditherNet,pn_newvalue(k),pn_newvaluesf(k),idxPoly(1)-1,1);
        pirelab.getBitConcatComp(ditherNet,[xorout(k),pn_newvaluesf(k)],pn_newvalue(k+1));

        pnout=[pnout,bitToXOr(end,k)];

    end



    comp=pirelab.getBitConcatComp(ditherNet,pnout,dithervalue);
    comp.addComment('Dither Output');
    dithervalue.SimulinkRate=dataRate;

end