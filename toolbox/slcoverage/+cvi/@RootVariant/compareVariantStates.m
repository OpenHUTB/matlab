function res=compareVariantStates(oldState,newState)




    try
        res=isequal(oldState,newState);
        if res
            return;
        end
        if numel(newState)~=numel(oldState)
            res=false;
            return;
        end
        for nidx=1:numel(newState)
            tvs=oldState({oldState.path}==string(newState(nidx).path));
            if isempty(tvs)||(tvs.state~=newState(nidx).state)
                res=false;
                return;
            end
        end
    catch MEx
        rethrow(MEx);
    end
end
