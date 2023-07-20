function objId=getRelationalBoundary(slsfCvId,idx)




















    objId=0;
    idx=idx+1;
    array=cv('MetricGet',slsfCvId,Sldv.CvApi.getMetricVal('cvmetric_Structural_relationalop'),'.baseObjs');


    if idx<=numel(array)
        objId=array(idx);
    end
