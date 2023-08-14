function[fc]=copyFeatureFlags(featureFlags,fc)




    if~isempty(char(featureFlags))
        try



            featureFlags=eval(featureFlags);
        catch me
            featureFlags={};
            coder.internal.gui.asyncDebugPrint(me);
        end
    end
    if~isempty(featureFlags)&&iscell(featureFlags)
        for i=1:2:numel(featureFlags)
            try
                fc.(featureFlags{i})=featureFlags{i+1};
            catch ex
                coder.internal.gui.asyncDebugPrint(ex);
            end
        end
    end
end

