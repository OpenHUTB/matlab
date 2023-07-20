

function warmupSymbolic()
    if strcmp(getenv('PREWARM_SYMBOLIC_TOOLBOX'),'true')


        try
            parallel.internal.lmgr.addFeatures("SYMBOLIC_TOOLBOX");
            syms x y;
            clear x y;
        catch
        end
        try
            parallel.internal.lmgr.clearFeatures();
        catch
        end

    end
end