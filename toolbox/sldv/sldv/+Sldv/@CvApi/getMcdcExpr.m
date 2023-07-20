function[condIdxs,postFixExpr]=getMcdcExpr(slsfCvId,mcdcId)














    condIdxs=[];
    postFixExpr=[];
    if(mcdcId<=0)
        return;
    end

    [postFixExpr,mcdcCondIds]=cv('get',mcdcId,'.bst','.conditions');
    mcdcCondKeys=cv('get',mcdcCondIds,'.key');
    if any(mcdcCondKeys==-1)





        if slavteng('feature','McdcFixes')&&cv('get',mcdcId,'.cascMCDC.isCascMCDC')==0
            allCondIdsForObj=cv('MetricGet',slsfCvId,Sldv.CvApi.getMetricVal('condition'),'.baseObjs');
            [~,condIdxs]=ismember(mcdcCondIds,allCondIdsForObj);
            condIdxs=condIdxs-1;
        else
            condIdxs=0:max(postFixExpr);
        end
    else

        allCondIdsForObj=cv('MetricGet',slsfCvId,Sldv.CvApi.getMetricVal('condition'),'.baseObjs');
        keyVec=cv('get',allCondIdsForObj,'.key');
        [~,condIdxs]=ismember(mcdcCondKeys,keyVec);
        condIdxs=condIdxs-1;
    end
end
