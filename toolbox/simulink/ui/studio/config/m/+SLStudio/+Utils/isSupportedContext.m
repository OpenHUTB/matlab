function res=isSupportedContext(cbinfo,supportedContexts,bdType)




    res=false;
    if isempty(supportedContexts)
        res=true;
    else
        for index=1:length(supportedContexts)
            if isa(cbinfo.domain,supportedContexts{index})
                res=true;
                break
            end
        end
    end



    if res==true&&nargin>2&&~isempty(bdType)
        res=strcmpi(cbinfo.model.BlockDiagramType,bdType);
    end
end
