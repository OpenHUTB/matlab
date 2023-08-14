function decision=slicerLUT(this,hN,LUTvalues,compout_sig,decision_name)









    if nargin<5
        decision_name='hardDecision';
    end

    LUTaddrWL=log2(numel(LUTvalues));


    addrT=hN.getType('FixedPoint','Signed',0,'WordLength',LUTaddrWL);
    addr=hN.addSignal2('Name','decisionLUTaddr','Type',addrT);


    LUTvalWL=log2(max(LUTvalues)+1);
    valT=hN.getType('FixedPoint','Signed',0,'WordLength',LUTvalWL);
    decision=hN.addSignal2('Name',decision_name,'Type',valT);


    LUTvaluesfi=fi(LUTvalues,0,LUTvalWL,0);



    pirelab.getBitConcatComp(hN,compout_sig,addr);
    pirelab.getDirectLookupComp(hN,addr,decision,LUTvaluesfi);

end

