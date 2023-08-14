function tgt=getMdlRefComplianceTable(~,type)

































    if strcmp(type,'RTW')
        tgt.ModelReferenceCompliant={0,0,{'on'}};
    else
        tgt=[];
    end

