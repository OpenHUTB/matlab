function executeDelayedParamChanges(p)



    pv=p.pDelayedParamChanges;
    if~isempty(pv)

        for i=1:2:numel(pv)
            p.(pv{i})=pv{i+1};
        end

        p.pDelayedParamChanges={};
    end
