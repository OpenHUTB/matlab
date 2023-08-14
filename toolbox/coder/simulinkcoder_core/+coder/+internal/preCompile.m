function preCompile...
    (componentName,mainObjFolder,targetType,...
    lDispHook,lClientChecksum,buildInfo,buildOpts)











    [includeChecksumsMatch,clientChecksumsMatch,lCompileInfo]=locCompileChecksumsMatch...
    (mainObjFolder,lClientChecksum,buildInfo,buildOpts);

    generatedCodeChanged=...
    ~clientChecksumsMatch(coder.internal.CompileChecksum.CodeGenerationId);

    coverageSettingsChangedForCompileDir=...
    ~clientChecksumsMatch(coder.internal.CompileChecksum.BuildHooks);

    lForceCompile=locIsCompileNeeded...
    (targetType,componentName,...
    lDispHook,coverageSettingsChangedForCompileDir,...
    includeChecksumsMatch,generatedCodeChanged);

    if lForceCompile

        deleteInfoFile(lCompileInfo);
    end
end


function forceCompile=locIsCompileNeeded...
    (targetType,componentName,...
    lDispHook,coverageSettingsChanged,...
    includesMatch,generatedCodeChanged)

    forceCompile=false;

    if~generatedCodeChanged
        if coverageSettingsChanged
            reason='codeCov';
        elseif~includesMatch


            forceCompile=true;
            reason='refModelChanged';
        else
            reason='';
        end

        if~isempty(reason)
            targetTypeReason=[targetType,'_',reason];
            switch(targetTypeReason)
            case 'SIM_codeCov'
                msgID='Simulink:slbuild:recompilingCodeInstrChangedSim';
            case 'RTW_codeCov'
                msgID='Simulink:slbuild:recompilingCodeInstrChangedCoder';
            case 'NONE_codeCov'
                msgID='Simulink:slbuild:recompilingCodeInstrChangedStandalone';
            case 'SIM_refModelChanged'
                msgID='Simulink:slbuild:recompilingModelRefSimTarget';
            case 'RTW_refModelChanged'
                msgID='Simulink:slbuild:recompilingModelRefCoderTarget';
            case 'NONE_refModelChanged'
                msgID='Simulink:slbuild:recompilingModelRefStandaloneTarget';
            end
            msg=DAStudio.message(msgID,componentName);
            feval(lDispHook,['### ',msg]);
        end
    end
end


function[includeChecksumsMatch,lClientChecksumsMatch,lCompileInfo]=...
locCompileChecksumsMatch...
    (compileInfoFolder,lClientChecksum,buildInfo,buildOpts)

    lCompileInfo=coder.make.internal.CompileInfoFile(compileInfoFolder);

    includesChecksum=coder.make.internal.getIncludeFileChecksums...
    (buildInfo,buildOpts.ClientAnchorFolder,...
    buildOpts.SkipIncludeFileChecksumFolders);
    setIncludeFilesChecksum(lCompileInfo,includesChecksum);
    includeChecksumsMatch=includeFilesChecksumMatches(lCompileInfo);

    setClientChecksum(lCompileInfo,lClientChecksum);
    lClientChecksumsMatch=clientChecksumsMatch(lCompileInfo);
end



