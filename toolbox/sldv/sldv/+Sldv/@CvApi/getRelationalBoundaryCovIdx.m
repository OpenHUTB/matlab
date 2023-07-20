function covIdx=getRelationalBoundaryCovIdx(slsfCvId,chkExprIdx)
































    covIdx=0;
    relopObjArray=cv('MetricGet',slsfCvId,Sldv.CvApi.getMetricVal('cvmetric_Structural_relationalop'),'.baseObjs');
    relopChkExprIdxArray=cv('get',relopObjArray,'.relopChkExprIdx');

    if(chkExprIdx<numel(relopChkExprIdxArray))&&...
        ((relopChkExprIdxArray(chkExprIdx+1)<0)||...
        (relopChkExprIdxArray(chkExprIdx+1)==chkExprIdx))





        covIdx=chkExprIdx;

    else




        for i=1:numel(relopChkExprIdxArray)
            if relopChkExprIdxArray(i)==chkExprIdx
                covIdx=i-1;
                return;
            end
        end
    end

