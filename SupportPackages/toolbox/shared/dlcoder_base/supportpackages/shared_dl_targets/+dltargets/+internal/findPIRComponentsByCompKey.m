function matchingComps=findPIRComponentsByCompKey(compKeys)





    p=dnn_pir;
    comps=p.getTopNetwork.Components();


    matchingIndices=zeros(numel(comps),1);
    for idx=1:numel(comps)
        for idy=1:numel(compKeys)
            if strcmp(comps(idx).getCompKey,compKeys{idy})
                matchingIndices(idx)=1;
            end
        end
    end

    matchingComps=comps(matchingIndices==1);
end
