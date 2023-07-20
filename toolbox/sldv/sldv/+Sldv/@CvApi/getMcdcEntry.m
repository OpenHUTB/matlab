function mcdcId=getMcdcEntry(slsfCvId,idx)




















    mcdcId=0;
    if(slsfCvId==0)
        return;
    end

    idx=idx+1;
    mcdcIdArray=cv('MetricGet',slsfCvId,Sldv.CvApi.getMetricVal('mcdc'),'.baseObjs');



    if(idx==0)
        if(numel(mcdcIdArray)==1)



            mcdcId=mcdcIdArray(1);
        end
    elseif idx<=numel(mcdcIdArray)
        mcdcId=mcdcIdArray(idx);
    end
