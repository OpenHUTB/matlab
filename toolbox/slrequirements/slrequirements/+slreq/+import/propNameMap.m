function out=propNameMap(in)



    persistent supportedNames
    if isempty(supportedNames)
        supportedNames={...
        'SKIP',getString(message('Slvnv:slreq_import:Skip'));...
        'customId',getString(message('Slvnv:slreq_import:PrimaryID'));...
        'summary',getString(message('Slvnv:slreq:Summary'));...
        'description',getString(message('Slvnv:slreq_import:Description'));...
        'rationale',getString(message('Slvnv:slreq_import:Rationale'));...
        'keywords',getString(message('Slvnv:slreq:Keywords'));...
        'ATTR',getString(message('Slvnv:slreq_import:CustomAttribute'));...
        'createdBy',getString(message('Slvnv:slreq:CreatedBy'));...
        'createdOn',getString(message('Slvnv:slreq:CreatedOn'));...
        'modifiedBy',getString(message('Slvnv:slreq:ModifiedBy'));...
        'modifiedOn',getString(message('Slvnv:slreq:ModifiedOn'))};
    end

    if nargin==0

        out=supportedNames(:,2);

    elseif ischar(in)

        idx=find(strcmpi(supportedNames(:,1),in));
        if isempty(idx)
            out=[];
        else
            out=idx-1;
        end

    else

        if in<size(supportedNames,1)
            out=supportedNames(in+1,:);
        else
            out={};
        end
    end

end
