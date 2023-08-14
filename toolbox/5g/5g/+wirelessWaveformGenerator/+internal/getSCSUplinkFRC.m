function scs=getSCSUplinkFRC(frNum,secNum,frcNum)








    commonFR1=[15,15,15,30,30,30,30];
    fr1SCS={[15,30,60,15,30,60,15,30,60],...
    [15,30,60,15,30,60],...
    [repmat(commonFR1,1,4),15,30,15,30],...
    repmat(commonFR1,1,4),...
    repmat(commonFR1,1,2)};

    commonFR2=[60,60,120,120,120];
    fr2SCS={[60,120,120,60,120],...
    [],...
    [repmat(commonFR2,1,2),60,120],...
    repmat(commonFR2,1,2),...
    commonFR2};


    if frNum==1
        scs=fr1SCS{secNum}(frcNum);
    else
        scs=fr2SCS{secNum}(frcNum);
    end
