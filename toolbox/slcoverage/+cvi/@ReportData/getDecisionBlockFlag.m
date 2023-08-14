function flags=getDecisionBlockFlag(decData)




    flags.noCoverage=0;
    flags.justified=any(decData.justifiedOutHitCnts>0);
    if(decData.outHitCnts(end)==decData.totalCnts)
        flags.fullCoverage=1;
        flags.noCoverage=0;
        flags.leafUncov=0;
        flags.justified=0;
    else
        flags.fullCoverage=0;
        flags.leafUncov=ne(decData.totalCnts,(decData.justifiedOutHitCnts(end)+decData.outHitCnts(end)));
        if decData.outHitCnts(end)==0
            flags.noCoverage=1;
        end
    end