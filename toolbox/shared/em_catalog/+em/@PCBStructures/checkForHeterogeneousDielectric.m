function checkForHeterogeneousDielectric(obj,propVal,dIndx)

    tempSub=propVal(dIndx);
    subEpsr=cellfun(@(x)(x.EpsilonR),tempSub,'UniformOutput',false);
    N=cellfun(@(x)numel(x),subEpsr);
    if any(N>1)
        if isa(obj,'pcbStack')
            error(message('antenna:antennaerrors:Unsupported','Heterogeneous dielectric layer','pcbStack dielectric layer'));
        else
            error(message('rfpcb:rfpcberrors:Unsupported','Heterogeneous dielectric layer','pcbComponent dielectric layer'));
        end
    end
end