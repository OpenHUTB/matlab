function res=hasSupportedModelRefs(topModelH)





    try
        simTypes={'Normal'};
        if SlCov.CoverageAPI.isCovAccelSimSupport(topModelH)
            simTypes{end+1}='Accelerator';
        end



        supportedrefs=cv.ModelRefData.getMdlReferences(topModelH,false,false,simTypes);
        res=~isempty(supportedrefs);
    catch
        res=false;
    end