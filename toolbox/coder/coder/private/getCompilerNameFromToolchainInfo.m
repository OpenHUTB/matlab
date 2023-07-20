function[compiler,compilerInfo,tcinfo]=getCompilerNameFromToolchainInfo(config)



    compiler='unknown compiler';
    compilerInfo.compilerName=compiler;
    compilerInfo.codingMicrosoftMakefile=false;
    compilerInfo.codingLcc64Makefile=false;
    compilerInfo.codingUnixMakefile=false;
    compilerInfo.codingIntelMakefile=false;

    tcinfo=coder.make.internal.getToolchainInfoFromName(config.Toolchain);
    if~isempty(tcinfo)
        if~isempty(tcinfo.Alias)
            compilerInfo.compilerName=tcinfo.Alias{1};
        end
        if~isempty(regexp(compilerInfo.compilerName,'^Microsoft-\d{1,2}.\d','once'))
            compiler='vcx64';
            compilerInfo.codingMicrosoftMakefile=1;
        elseif~isempty(regexpi(compilerInfo.compilerName,'^INTELC\d\dMS','once'))
            compiler='intelvcx64';
            compilerInfo.codingIntelMakefile=true;
        else
            switch(compilerInfo.compilerName)
            case 'LCC-x'
                compiler='lcc64';
                compilerInfo.codingLcc64Makefile=1;
            case{'Apple-x','GNU-x'}
                compiler='unix_cc';
                compilerInfo.codingUnixMakefile=1;
            otherwise

                if coder.make.internal.buildMethodIsCMake(tcinfo)
                    if tcinfo.isMSVC
                        compilerInfo.codingMicrosoftMakefile=1;
                    elseif tcinfo.isUNIX||tcinfo.isMinGW
                        compilerInfo.codingUnixMakefile=1;
                    end
                elseif ispc
                    compilerInfo.codingMicrosoftMakefile=1;
                else
                    compilerInfo.codingUnixMakefile=1;
                end
            end
        end
    end
end