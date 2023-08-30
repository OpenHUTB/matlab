function outputArr=randomNumberGen(inpRange,numSamples)

%#codegen

    coder.gpu.kernelfun;
    coder.inline('always');
    coder.allowpcode('plain');
    generatorStruct=coder.const(feval('rng'));
    randomNumberSeed=coder.const(generatorStruct.Seed);
    randomNumberType=coder.const(generatorStruct.Type);

    outputArr=randiGpuImpl(inpRange,numSamples,randomNumberSeed,randomNumberType);

end


function outArray=randiGpuImpl(inpRange,inpNumPoints,randomNumberSeed,randomNumberType)
%#codegen
    coder.gpu.kernelfun;
    outArray=coder.nullcopy(zeros(1,inpNumPoints,'uint32'));

    coder.cinclude('curand.h');
    if~coder.target('MEX')
        if coder.const(feval('isunix'))
            coder.updateBuildInfo('addLinkFlags','-lcurand');
        else
            coder.updateBuildInfo('addLinkFlags','curand.lib');
        end
    end
    randGen=coder.opaque('curandGenerator_t','0');
    if strcmp(randomNumberType,'twister')
        rngType=coder.opaque('curandRngType_t','CURAND_RNG_PSEUDO_MT19937');
    elseif strcmp(randomNumberType,'philox')
        rngType=coder.opaque('curandRngType_t','CURAND_RNG_PSEUDO_PHILOX4_32_10');
    elseif strcmp(randomNumberType,'combRecursive')
        rngType=coder.opaque('curandRngType_t','CURAND_RNG_PSEUDO_MRG32K3A');
    else
        rngType=coder.opaque('curandRngType_t','CURAND_RNG_PSEUDO_PHILOX4_32_10');
    end
    coder.ceval('curandCreateGenerator',coder.ref(randGen),rngType);
    coder.ceval('curandSetPseudoRandomGeneratorSeed',randGen,randomNumberSeed);
    coder.ceval('curandGenerate',randGen,coder.ref(outArray,'gpu'),inpNumPoints);
    coder.ceval('curandDestroyGenerator',randGen);

    outArray=mod(outArray,inpRange);
end

