function[rootID,sigID]=getRootAndSigID(item)






    rootID=item.id;
    sigID=item.id;
    if contains(item.Type,'Complex')
        sigID=item.ComplexID;
        rootID=item.ComplexID;
    end

    if isnumeric(item.parent)
        repo=starepository.RepositoryUtility;
        meta=repo.getMetaDataStructure(item.parent);
        if contains(meta.dataformat,'multi')||contains(meta.dataformat,'ND')...
            ||contains(meta.dataformat,'ndim')||contains(meta.dataformat,'non_scalar')
            rootID=item.parent;
        end
    end

end