function[isSupported]=compilerSupportsPthread()
    selectedCompiler=mex.getCompilerConfigurations('C','Selected');
    shortNameLower=lower(selectedCompiler.ShortName);
    isSupported=strcmp(shortNameLower,'gcc')||strcmp(shortNameLower,'clang');


