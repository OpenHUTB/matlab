function warmupGPU()
    if strcmp(getenv('PREWARM_GPU'),'true')
        disp('Checking GPU availability on Worker');


        try
            parallel.internal.lmgr.addFeatures("Distrib_Computing_Toolbox");
            mls.internal.feature('gpu','on');
        catch
        end
        try
            parallel.internal.lmgr.clearFeatures();
        catch
        end

        if strcmp(mls.internal.feature('gpu','status'),'on')
            disp('GPU available on Worker');


            setenv('PATH',['/usr/local/cuda/bin:',getenv('PATH')]);
        end
    end
end
