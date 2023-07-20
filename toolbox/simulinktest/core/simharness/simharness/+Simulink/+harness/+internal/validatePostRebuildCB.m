function validatePostRebuildCB(postRebuildCallback)

    if~isempty(postRebuildCallback)


        try
            res=which(postRebuildCallback,'all');
            if isempty(res)
                Simulink.harness.internal.warn({'Simulink:Harness:PostRebuildCBNotFound',postRebuildCallback});
            else
                if~iscell(res)
                    res={res};
                end
                res=regexp(res,'\.m');
                if all(cellfun(@isempty,res))
                    Simulink.harness.internal.warn({'Simulink:Harness:PostRebuildCBNotFound',postRebuildCallback});
                end
            end
        catch
            Simulink.harness.internal.warn({'Simulink:Harness:PostRebuildCBNotFound',postRebuildCallback});
        end
    end
end