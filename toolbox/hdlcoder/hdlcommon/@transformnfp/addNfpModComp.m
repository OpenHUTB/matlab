function hNew=addNfpModComp(hN,slRate,isSingle)
    if isSingle
        maxIterations=transformnfp.getModRemMaxIterations();
        checkResetToZero=transformnfp.getModRemCheckResetToZero();
        hNew=transformnfp.getSingleModRemComp(hN,slRate,'mod',maxIterations,checkResetToZero);
    end
end
