function parameters=selectParameters(operationFcnName,specification,buildContext,expectedOutputClass)






















    parameterSelector=dlcoderfeature('OptimizedAlgoParamsSelector');

    if isempty(parameterSelector)||~dltargets.internal.isNonAbstractClassMethod(parameterSelector,...
        operationFcnName)


        parameterSelector=coder.internal.layer.parameterSelector.selectorDispatcher(buildContext);
    end

    parameters=feval(operationFcnName,parameterSelector,specification,buildContext);

    assert(isa(parameters,expectedOutputClass),...
    "dlcoder_spkg:CodeGenerator:IncorrectClassOutput",operationFcnName,...
    expectedOutputClass);



    if strcmp(dlcoder_base.internal.getBuildWorkflow(buildContext),'simulation')

        assert(dlcoderfeature('LibraryFreeSimulinkSimulation'),...
        'LibraryFreeSimulinkSimulation is expected to be true')
        parameters.SimdWidth=1;
    end

    if strcmp(operationFcnName,'selectConvolutionParameters')
        parameters=iSetSimdWidthForConvolutionParameters(parameters,buildContext);
        parameters=iSetMaxMinIntrinsic(parameters,buildContext);
    end

end

function parameters=iSetSimdWidthForConvolutionParameters(parameters,buildContext)

    assert(isa(parameters,'coder.internal.layer.convUtils.CgirCpuParameters'),...
    "We should only call iSetSimdWidthForConvolutionParameters for convolution parameters.");

    if parameters.SimdWidth==-1

        dataType='single';
        parameters=setSimdWidthToLargest(parameters,dataType,buildContext);
    end

end




function parameters=iSetMaxMinIntrinsic(parameters,buildContext)

    assert(isa(parameters,'coder.internal.layer.convUtils.CgirCpuParameters'),...
    "We should only call iSetMaxMinIntrinsic for convolution parameters.");

    instructionSetExtensions=buildContext.getConfigProp('InstructionSetExtensions');


    if iscell(instructionSetExtensions)
        instructionSetExtensions=instructionSetExtensions{1};
    end

    codeReplacementLibrary=buildContext.getConfigProp('CodeReplacementLibrary');

    parameters.MaxMinIntrinsic=iGetMaxMinIntrinsic(instructionSetExtensions,codeReplacementLibrary);

end




















function maxMinIntrinsic=iGetMaxMinIntrinsic(instructionSetExtensions,codeReplacementLibraries)
    intelExtensions={'SSE','SSE2','SSE4.1','AVX','AVX2','FMA','AVX512F'};
    isIntelExtension=~isempty(instructionSetExtensions)&&...
    ismember(instructionSetExtensions,intelExtensions);

    intelCodeReplacementLibraries={'Intel SSE (Linux)',...
    'Intel SSE (Windows)',...
    'Intel AVX (Linux)',...
    'Intel AVX (Windows)',...
    'Intel AVX-512 (Linux)',...
    'Intel AVX-512 (Windows)',...
    };


    isIntelCodeReplacementLibrary=~isempty(codeReplacementLibraries)&&...
    any(cellfun(@(x)contains(codeReplacementLibraries,x),intelCodeReplacementLibraries));

    isArmCoreReplacementLibrary=~isempty(codeReplacementLibraries)&&...
    contains(codeReplacementLibraries,'GCC ARM Cortex-A');

    maxMinIntrinsic=0;
    if isIntelExtension||isIntelCodeReplacementLibrary
        maxMinIntrinsic=1;
    elseif isArmCoreReplacementLibrary
        maxMinIntrinsic=2;
    end
end
