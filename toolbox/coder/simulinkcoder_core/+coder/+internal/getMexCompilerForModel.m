function[lMexCompilerKey,lToolchainInfo,...
    lToolchainInfoError,lTMFProperties,isToolchainApproach]=getMexCompilerForModel...
    (lConfigSet,mexCompInfoDefault)





    lTMFProperties=[];

    if~isempty(mexCompInfoDefault)
        lDefaultMexKey=mexCompInfoDefault.compStr;
    else
        lDefaultMexKey='';
    end


    tcNameFromCs=get_param(lConfigSet,'Toolchain');
    isGPU=strcmpi(get_param(lConfigSet,'GenerateGPUCode'),'CUDA');
    isGPUHardware=strcmp(get_param(lConfigSet,'HardwareBoard'),'NVIDIA Jetson')...
    ||strcmp(get_param(lConfigSet,'HardwareBoard'),'NVIDIA Drive');

    [lToolchainInfo,lToolchainInfoError]=...
    coder.internal.getToolchainInfoFromConfigParam(tcNameFromCs,lDefaultMexKey,isGPU,isGPUHardware);

    isToolchainApproach=coder.internal.isConfigSetToolchainCompliant(lConfigSet,lToolchainInfo);

    if~isToolchainApproach
        isMSVCProjectBuild=i_isMSVCProjectBuild(lConfigSet);
        if isMSVCProjectBuild

            mexCompInfo=coder.make.internal.getMexCompilerInfo('MSVCBuildCompatible');
            if isempty(mexCompInfo)
                lToolchainInfo=[];
            else
                lMexCompilerKey=mexCompInfo.compStr;
                tcName=coder.make.internal.getToolchainNameFromRegistry(lMexCompilerKey);
                lToolchainInfo=coder.make.internal.getToolchainInfoFromRegistry(tcName);
            end
        else

            lTMFProperties=i_getCompilerInfoForTMF...
            (lConfigSet,mexCompInfoDefault);
            if~isempty(lTMFProperties)
                lToolchainInfo=lTMFProperties.Toolchain;
            else
                lToolchainInfo=[];
            end
        end
    end



    lMexCompilerKey='';
    if~isempty(lToolchainInfo)&&lToolchainInfo.SupportsBuildingMEXFuncs
        lMexCompilerKey=lToolchainInfo.Alias{1};
    end


end


function isMSVCProjectBuild=i_isMSVCProjectBuild(cs)
    lTemplateMakefile=get_param(cs,'TemplateMakefile');
    isMSVCProjectBuild=contains(lTemplateMakefile,'RTW.MSVCBuild');
end


function lTMFProperties=i_getCompilerInfoForTMF(cs,mexCompInfoDefault)

    lTMFProperties=[];
    if strcmp(get_param(cs,'GenerateMakefile'),'off')
        return;
    end

    if~isempty(mexCompInfoDefault)&&...
        (strcmp(mexCompInfoDefault.toolChain,'mingw64')||...
        strcmp(mexCompInfoDefault.toolChain,'intel'))

        mexCompInfo=coder.make.internal.getMexCompilerInfo('tmfcompatible');
        if ispc&&isempty(mexCompInfo)
            mexCompInfo=coder.make.internal.getMexCompInfoFromKey('LCC-x');
        end
    else
        mexCompInfo=mexCompInfoDefault;
    end


    tmf=get_param(cs,'TemplateMakefile');
    isGenCodeOnly=strcmp(get_param(cs,'GenCodeOnly'),'on');





    modelH=getModel(cs);
    if isempty(modelH)
        modelOrCs=cs;
    else
        modelOrCs=modelH;
    end
    try
        tmfFullPath=coder.make.internal.getTMF(modelOrCs,tmf,mexCompInfo);
    catch e
        if any(strcmp(e.identifier,...
            {'RTW:makertw:tmfUnavailable',...
            'RTW:makertw:tmfUnspecified',...
            'RTW:makertw:invalidTMF'}))...
            &&...
isGenCodeOnly


            tmfFullPath='';
        else
            rethrow(e)
        end
    end
    lTMFProperties=coder.make.internal.getTMFProperties...
    (tmfFullPath,mexCompInfo.compStr);
end
