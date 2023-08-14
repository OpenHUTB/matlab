function res=isCompatible(this,cvd)



    res={};
    allNames=this.allNames;
    for idx=1:numel(allNames)
        cn=allNames{idx};
        ccvd=this.get(cn);
        res=[res,ccvd.isCompatible(cvd)];%#ok<AGROW>
    end


