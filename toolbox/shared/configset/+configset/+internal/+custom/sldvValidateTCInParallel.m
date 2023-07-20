function[st,dcr]=sldvValidateTCInParallel(~,~)




    dcr='not available when Parallel Simulation is disabled';

    try
        if(slavteng('feature','UseParallelSimulations')&&...
            matlab.internal.parallel.isPCTInstalled()&&...
            matlab.internal.parallel.isPCTLicensed())
            st=0;
            return
        end
    catch
    end

    st=3;

