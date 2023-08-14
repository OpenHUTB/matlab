function supports_ipp=compiler_supports_eml_ipp(compilerName)



    supports_ipp=true;
    if strcmp(compilerName,'lcc64')
        supports_ipp=false;
    end
