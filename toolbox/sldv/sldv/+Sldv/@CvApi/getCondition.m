function objId=getCondition(slsfCvId,idx)




















    objId=0;

    if((slsfCvId==0)||(idx<0))
        return;
    end

    array=cv('MetricGet',slsfCvId,Sldv.CvApi.getMetricVal('condition'),'.baseObjs');
    idx=idx+1;


    if idx<=numel(array)
        objId=array(idx);
    end
