function doCModuleActions(modelName,md5ChecksumStr,fallbackInfo,targetDirName,nrInfo,codingOpenMP)







    usedTargetFunctionLibH=get_param(modelName,'SimTargetFcnLibHandle');

    auxInfo=collect_crl_dependencies(usedTargetFunctionLibH,targetDirName,[]);
    auxInfo.codingOpenMP=codingOpenMP;
    auxInfo.codingSIMD=getSIMDInstructionSets(usedTargetFunctionLibH);

    matFilePath=fullfile(targetDirName,['m_',md5ChecksumStr,'.mat']);
    varList.fallbackInfo=fallbackInfo;
    varList.auxInfo=auxInfo;
    varList.buildInfoUpdate=cgxe('BuildInfoUpdate',modelName);
    varList.NameResolution=nrInfo;%#ok<STRNU>

    save(matFilePath,'-struct','varList');

    if~isfile(matFilePath)
        saveException=MException(message('Simulink:cgxe:FileNotFound',...
        matFilePath,fileNameInfo.targetDirName));
        throw(saveException);
    end

    codeModuleCFiles(modelName,md5ChecksumStr,fallbackInfo,targetDirName,codingOpenMP);

end

function simd=getSIMDInstructionSets(fcnLib)
    simd='';
    if~strcmp(fcnLib.LoadedLibrary,'Simulation Target IPP BLAS SIMD')
        return;
    end

    instructionSets=lower(fcnLib.InstructionSets);

    if any(contains(instructionSets,"avx512"))
        simd='AVX512';
    elseif any(contains(instructionSets,"avx"))
        simd='AVX2';
    elseif any(contains(instructionSets,"sse"))
        simd='SSE2';
    end
end


