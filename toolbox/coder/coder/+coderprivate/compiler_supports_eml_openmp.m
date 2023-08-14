function supported_compiler=compiler_supports_eml_openmp(compilerName)



    supported_compiler=true;
    if strcmp(compilerName,'lcc64')
        supported_compiler=false;
    end





