function result=isMexFileUpToDate(mexFile)
    result=coder.internal.TestBenchManager.verifyResolvedFunctions(mexFile);
end