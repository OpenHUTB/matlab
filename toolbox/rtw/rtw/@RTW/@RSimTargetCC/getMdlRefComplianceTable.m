function tgt=getMdlRefComplianceTable(hObj,type)



































    if strcmp(type,'RTW')
        tgt.ModelReferenceCompliant={0,0,{'on'}};
        tgt.ExtMode={1,2,{'off'}};
        tgt.RSIM_PARAMETER_LOADING={1,2,{'off'}};
    else
        tgt=[];
    end
