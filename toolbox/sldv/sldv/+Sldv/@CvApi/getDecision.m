function objId=getDecision(slsfCvId,idx)




















    objId=0;
    idx=idx+1;
    array=cv('MetricGet',slsfCvId,Sldv.CvApi.getMetricVal('decision'),'.baseObjs');


    if idx<=numel(array)
        objId=array(idx);
    end
