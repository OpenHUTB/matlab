function[ids,domainParams]=getIdAndParamsForDomain(this,domainType,blockH)









    domainParams=[];
    ids={};

    if(nargin<2)
        return;
    end

    fullPath='';
    if(nargin>2)
        fullPath=getfullname(blockH);
    end

    len=this.Count;
    for idx=1:len
        sig=get(this,idx,true);
        blockSID=Simulink.ID.getSID(blockH);

        if~isempty(fullPath)&&...
            ~isequal(blockSID,sig.SID_)
            continue;
        end

        if~strcmp(sig.DomainType_,domainType)
            continue;
        end

        if isempty(domainParams)
            domainParams=sig.DomainParams_;
        else
            domainParams(end+1)=sig.DomainParams_;%#ok<AGROW>
        end

        ids{end+1}=sig.UUID;%#ok<AGROW>
    end
end
