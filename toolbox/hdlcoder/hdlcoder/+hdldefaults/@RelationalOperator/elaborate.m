function hNewC=elaborate(this,hN,hC)



    [op,inputSameDT]=getBlockInfo(this,hC);

    if strcmp(inputSameDT,'off')
        sameDT=false;
    else
        sameDT=true;
    end


    hInSignals=hC.SLInputSignals;
    nfpOptions=getNFPBlockInfo(this);

    hNewC=pirelab.getRelOpComp(hN,hInSignals,hC.SLOutputSignals,op,sameDT,hC.Name,'',-1,nfpOptions);
