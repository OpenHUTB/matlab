function out=resetUsingToolchainApproach(cs,name,direction,widgetVals)




    cs=cs.getConfigSet;

    if direction==0
        if isempty(cs)
            out={''};
        else
            out={cs.get_param(name)};
        end
    elseif direction==1
        out=widgetVals{1};
        configset.internal.util.toolchainRelevantItemChanged(cs);
    end

