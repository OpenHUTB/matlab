function preprocessorFlags=getToolchainCustomDefines...
    (lToolchainInfo,lCustomToolchainOptions,lIsCpp)




    preprocessorFlags={};

    if lIsCpp
        toolName='C++ Compiler';
    else
        toolName='C Compiler';
    end

    compilerFlags='';
    for optionIdx=1:2:length(lCustomToolchainOptions)
        if strcmp(lCustomToolchainOptions(optionIdx),toolName)
            compilerFlags=lCustomToolchainOptions{optionIdx+1};
            break;
        end
    end

    if~isempty(compilerFlags)
        buildtool=lToolchainInfo.getBuildTool(toolName);
        preprocessorDirective=buildtool.getDirective('PreprocessorDefine');


        pattern=[preprocessorDirective,'(\s*)("*)(\s*)(\w*)(\s*)(=*)(\s*)(\w*)(\s*)("*)'];
        preprocessorFlags=regexp(compilerFlags,pattern,'match');
        preprocessorFlags=strrep(preprocessorFlags,preprocessorDirective,'');
    end
