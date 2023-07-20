function ret=getComparisonRunSource(compareRunID,type)





    ret=0;

    repo=sdi.Repository(1);
    switch lower(char(type))
    case 'baseline'
        ret=repo.getBaselineRunID(compareRunID);
    case 'compareto'
        ret=repo.getCompareToRunID(compareRunID);
    end
end