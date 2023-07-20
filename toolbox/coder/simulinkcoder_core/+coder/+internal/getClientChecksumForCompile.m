function lClientChecksum=getClientChecksumForCompile(lBuildHookHandles,lCodeGenerationId)






    [~,checksumNames]=enumeration('coder.internal.CompileChecksum');
    checksumValues=cell(size(checksumNames));

    if~isempty(lBuildHookHandles)
        checksumValues{coder.internal.CompileChecksum.BuildHooks}=...
        {coder.coverage.buildHooksGetChecksum(lBuildHookHandles)};
    end

    checksumValues{coder.internal.CompileChecksum.CodeGenerationId}=lCodeGenerationId;

    lClientChecksum=struct('Name',checksumNames,'Value',checksumValues);
