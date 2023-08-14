function[compileModes,licenses,hasFixit]=parseAndValidateSubcheckCfg(this,sccfg)




    if~isstruct(sccfg)
        error('Subcheck configuration given to the check is not a struct');
    end

    numlevels=numel(sccfg);

    compileModes={};
    licenses={};
    hasFixit=false;

    for i=1:numlevels
        if~isfield(sccfg(i),'Type')
            error('Subcheck configuration does not specify a field named "Type"');
        end

        if strcmp(sccfg(i).Type,'Normal')
            SO=slcheck.getSubCheckObject(sccfg(i).subcheck);
            SO.MessageCatalogPrefix=this.CheckCatalogPrefix;

            compileModes=[compileModes;SO.CompileMode];%#ok<AGROW>
            if~isempty(SO.Licenses)
                licenses=[licenses,SO.Licenses];%#ok<AGROW>
            end

            hasFixit=hasFixit||ismethod(SO,'fixit');


        elseif strcmp(sccfg(i).Type,'Group')
            for j=1:numel(sccfg(i).subcheck)
                SO=slcheck.getSubCheckObject(sccfg(i).subcheck(j));
                SO.MessageCatalogPrefix=this.CheckCatalogPrefix;

                compileModes=[compileModes;SO.CompileMode];%#ok<AGROW>
                if~isempty(SO.Licenses)
                    licenses=[licenses,SO.Licenses];%#ok<AGROW>
                end
                hasFixit=hasFixit||ismethod(SO,'fixit');

            end

        else
            error('Invalid Type setting on Subcheck Config');
        end
    end

end


