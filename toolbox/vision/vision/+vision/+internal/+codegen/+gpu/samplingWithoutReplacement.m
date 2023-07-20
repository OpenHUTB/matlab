

function outputArray=samplingWithoutReplacement(inpRange,numSamples)
%#codegen





















    coder.gpu.kernelfun;
    coder.inline('always');
    coder.allowpcode('plain');


    randGen=coder.const(feval('rng'));
    randSeed=coder.const(randGen.Seed);
    randType=coder.const(randGen.Type);


    outputArray=randpermGpuImpl(inpRange,numSamples,randSeed,randType);
end


function outArray=randomNumGen(inpNumPoints,randStateVal,genType)
%#codegen

    coder.gpu.kernelfun;
    coder.inline('never');

    if nargin<3
        genType='philox';
    end


    coder.cinclude('curand.h');
    if~coder.target('MEX')
        if coder.const(feval('isunix'))
            coder.updateBuildInfo('addLinkFlags','-lcurand');
        else
            coder.updateBuildInfo('addLinkFlags','curand.lib');
        end
    end


    generatorStruct=coder.opaque('curandGenerator_t','0');
    if strcmp(genType,'twister')
        rngType=coder.opaque('curandRngType_t','CURAND_RNG_PSEUDO_MT19937');
    elseif strcmp(genType,'philox')
        rngType=coder.opaque('curandRngType_t','CURAND_RNG_PSEUDO_PHILOX4_32_10');
    elseif strcmp(genType,'combRecursive')
        rngType=coder.opaque('curandRngType_t','CURAND_RNG_PSEUDO_MRG32K3A');
    else
        coder.gpu.internal.diagnostic('gpucoder:diagnostic:PcdownsampleUnsupportedRandomNumberGenerator');
        rngType=coder.opaque('curandRngType_t','CURAND_RNG_PSEUDO_PHILOX4_32_10');
    end
    coder.ceval('curandCreateGenerator',coder.ref(generatorStruct),rngType);


    coder.ceval('curandSetPseudoRandomGeneratorSeed',generatorStruct,randStateVal);


    outArray=coder.nullcopy(zeros(1,inpNumPoints,'uint32'));


    coder.ceval('curandGenerate',generatorStruct,coder.ref(outArray,'gpu'),inpNumPoints);

    coder.ceval('curandDestroyGenerator',generatorStruct);

end


function outArr=randpermGpuImpl(inpRange,outNum,randNumSeed,genType)
%#codegen

    coder.gpu.kernelfun;
    coder.inline('never');
    if nargin<4
        genType='philox';
    end





    randArr=mod(randomNumGen(inpRange,randNumSeed,genType),inpRange)+1;
    [~,sortedIdx]=gpucoder.sort(randArr);
    outArr=cast(sortedIdx(1:outNum),'uint32');
end
