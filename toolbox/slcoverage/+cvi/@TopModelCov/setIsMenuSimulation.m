function setIsMenuSimulation(modelH,val)




    try
        coveng=cvi.TopModelCov.getInstance(modelH);
        if~isempty(coveng)
            coveng.isMenuSimulation=val;
        end
    catch MEx
        rethrow(MEx);
    end
