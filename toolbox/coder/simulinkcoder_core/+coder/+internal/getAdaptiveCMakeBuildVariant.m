function[isAdaptiveToolchain,adapCmakeBuildVariant]=getAdaptiveCMakeBuildVariant(modelName)









    tcName=get_param(modelName,'Toolchain');
    isAdaptiveToolchain=true;

    switch tcName
    case 'AUTOSAR Adaptive | CMake'

        adapCmakeBuildVariant=coder.make.enum.BuildVariant.STANDALONE_EXECUTABLE;



        buildConfig=get_param(modelName,'BuildConfiguration');

        if strcmp(buildConfig,'Specify')
            tcSpecify=get_param(modelName,'CustomToolchainOptions');
            targetTypeIndex=find(strcmp(tcSpecify,'CMake Target Type'))+1;
            targetTypeStrOrig=strip(tcSpecify{targetTypeIndex});
            targetTypeStr=lower(targetTypeStrOrig);





            if~any(strcmp(targetTypeStr,{'executable','shared','static'}))
                DAStudio.error('MATLAB:validatestring:unrecognizedStringChoice3',...
                '"CMake Target Type" input',['''Executable''',', ''Shared''',', ''Static'''],...
                targetTypeStrOrig);
            end

            switch targetTypeStr
            case 'shared'
                adapCmakeBuildVariant=coder.make.enum.BuildVariant.SHARED_LIBRARY;
            case 'static'
                adapCmakeBuildVariant=coder.make.enum.BuildVariant.STATIC_LIBRARY;
            otherwise
                adapCmakeBuildVariant=coder.make.enum.BuildVariant.STANDALONE_EXECUTABLE;
            end
        end

    case 'AUTOSAR Adaptive Linux Executable'

        adapCmakeBuildVariant=coder.make.enum.BuildVariant.STANDALONE_EXECUTABLE;

    otherwise

        isAdaptiveToolchain=false;
        adapCmakeBuildVariant=coder.make.enum.BuildVariant.UNKNOWN;
    end

    if isAdaptiveToolchain&&~Simulink.CodeMapping.isAutosarAdaptiveSTF(modelName)


        isAdaptiveToolchain=false;
        adapCmakeBuildVariant=coder.make.enum.BuildVariant.UNKNOWN;
        MSLDiagnostic('autosarstandard:validation:STFNotSupportedForToolchain',...
        get_param(modelName,'Toolchain'),modelName).reportAsWarning;
    end
end


