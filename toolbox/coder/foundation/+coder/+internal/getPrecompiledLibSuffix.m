function lPrecompTargetLibSuffix=getPrecompiledLibSuffix...
    (lIsPurelyIntegerCode,lToolchainInfo,lSystemTargetFile,...
    isSIMTargetType,targetLibSuffixFromCs,...
    lMexCompilerLibSuffix)






    if~isempty(targetLibSuffixFromCs)
        lPrecompTargetLibSuffix=targetLibSuffixFromCs;
        return;
    end

    [~,fTmp,eTmp]=fileparts(lSystemTargetFile);
    lSysTargetFileNoPath=[fTmp,eTmp];


    if~isempty(lToolchainInfo)
        lTargetLibraryExtension=coder.make.internal.getLibExtension(lToolchainInfo);
    else
        lTargetLibraryExtension=['.',coder.make.internal.getLibExtension()];
    end






    lPrecompTargetLibSuffix=i_getPreCompLibSuffix...
    (lIsPurelyIntegerCode,lMexCompilerLibSuffix,...
    lSysTargetFileNoPath,isSIMTargetType,lTargetLibraryExtension);




    function lPrecompTargetLibSuffix=i_getPreCompLibSuffix...
        (lIsPurelyIntegerCode,lMexCompilerLibSuffix,lSystemTargetFile,...
        isSIMTargetType,lTargetLibraryExtension)

        if~isempty(lMexCompilerLibSuffix)&&~strcmp(lMexCompilerLibSuffix,'unix')
            toolchainID=['_',lMexCompilerLibSuffix];
        else
            toolchainID='';
        end

        stf=strtok(lSystemTargetFile,'.');

        if isSIMTargetType
            libSuffix=['_rtwsfcn',toolchainID];
        elseif lIsPurelyIntegerCode
            libSuffix=['_int_',stf,toolchainID];
        else
            if strcmpi(stf,'ert')
                libSuffix=['_',stf,toolchainID];
            elseif strcmpi(stf,'slrealtime')
                libSuffix=['_slrt_x64',toolchainID];
            else
                if ispc
                    libSuffix=toolchainID;
                else
                    libSuffix='_std';
                end
            end
        end

        lPrecompTargetLibSuffix=...
        [libSuffix,lTargetLibraryExtension];


