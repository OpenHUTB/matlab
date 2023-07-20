function isSimCodegen=IsSysObjSimInCodeGen(coderTarget)












    isSimCodegen=false;

    switch lower(coderTarget)
    case 'mex'
        isSimCodegen=true;
    case 'sfun'
        isSimCodegen=true;
    end

    isSimCodegen=isSimCodegen|dsp.enhancedsim.IsModelSimInCodeGenTLC;

    isSimCodegen=isSimCodegen|dsp.internal.feature("dspunfoldOptimizedCG","enable");
end