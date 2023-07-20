function newParams=removeTransientParams(this,params)










    newParams=params;
    if~isempty(params)
        paramNames=lower(params(1:2:end));
        transientParams=lower(this.getTransientPropNameList);





        DontSetParams=intersect(transientParams,paramNames);
        if~isempty(DontSetParams)
            newParams=cell(1,numel(params)-2*numel(DontSetParams));
            npIdx=1;
            for ii=1:numel(paramNames)
                p=paramNames{ii};
                if~any(strcmp(p,DontSetParams))
                    pIdx=2*ii-1;
                    newParams{npIdx}=params{pIdx};
                    newParams{npIdx+1}=params{pIdx+1};
                    npIdx=npIdx+2;
                end
            end
        end
    end
end


