function hNew=addNfpRemComp(hN,slRate,isSingle)
    if isSingle
        maxIterations=transformnfp.getModRemMaxIterations();
        checkResetToZero=transformnfp.getModRemCheckResetToZero();
        hNew=transformnfp.getSingleModRemComp(hN,slRate,'rem',maxIterations,checkResetToZero);
    end
end
