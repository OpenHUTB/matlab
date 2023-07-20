function ccInfo=init(topModelH)







    try
        coveng=cvi.TopModelCov.getInstance(topModelH);
        if~isa(coveng,'cvi.TopModelCov')||...
            coveng.topModelH~=topModelH||...
            ~cvi.TopModelCov.isTopMostModel(topModelH)
            ccInfo=struct([]);
            return
        end


        cvi.SLCustomCodeCov.setup(coveng);


        ccInfo=coveng.slccCov.toInfoStruct();
    catch MEx
        rethrow(MEx);
    end