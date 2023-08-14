function nrb=getNRBUplinkFRC(frNum,secNum,frcNum)








    commonFR1=[25,52,106,24,51,106,273];
    fr1NRB={[25,11,11,106,51,24,15,6,6],...
    [25,11,11,106,51,24],...
    [repmat(commonFR1,1,4),25,24,25,24],...
    repmat(commonFR1,1,4),...
    repmat(commonFR1,1,2)};

    commonFR2=[66,132,32,66,132];
    fr2NRB={[66,32,66,33,16],...
    [],...
    [repmat(commonFR2,1,2),30,30],...
    repmat(commonFR2,1,2),...
    commonFR2};


    if frNum==1
        nrb=fr1NRB{secNum}(frcNum);
    else
        nrb=fr2NRB{secNum}(frcNum);
    end
