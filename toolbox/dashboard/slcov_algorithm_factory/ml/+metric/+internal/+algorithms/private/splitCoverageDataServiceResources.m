






function[cdsBase,cdsSubset]=splitCoverageDataServiceResources(cdsResources,subsetId)
    cdsBase=[];
    cdsSubset=[];

    if numel(cdsResources)~=2
        return
    end

    if strcmp(cdsResources(1).DataServiceInstanceID,subsetId)
        cdsSubset=cdsResources(1);
    elseif strcmp(cdsResources(1).DataServiceInstanceID,'CoverageDataService')
        cdsBase=cdsResources(1);
    end

    if strcmp(cdsResources(2).DataServiceInstanceID,subsetId)
        cdsSubset=cdsResources(2);
    elseif strcmp(cdsResources(2).DataServiceInstanceID,'CoverageDataService')
        cdsBase=cdsResources(2);
    end

end

