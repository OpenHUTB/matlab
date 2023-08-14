function recipientBuildInfoIsUpToDate=mergeBuildInfoContent(donorBuildInfo,recipientBuildInfo)






    recipientBuildInfoIsUpToDate=true;



validateAgainstDonorRequirements...
    (recipientBuildInfo.CompilerRequirementsDirect,...
    donorBuildInfo.CompilerRequirementsDirect);



    discardDefines={
'TID01EQ'
'MODEL'
'NUMST'
'NCSTATES'
'NUMST'
'NCSTATES'
'HAVESTDIO'
'MODEL_HAS_DYNAMICALLY_LOADED_SFCNS'
'CLASSIC_INTERFACE'
'ALLOCATIONFCN'
'TERMFCN'
'ONESTEPFCN'
'MAT_FILE'
'MULTI_INSTANCE_CODE'
'MATLAB_MEX_FILE'
'RT'
'MT'
    'MDL_REF_SIM_TGT'};



    [~,existingDefines]=recipientBuildInfo.getDefines;
    [~,modelDefines]=donorBuildInfo.getDefines;
    [~,copyIdx]=setdiff(modelDefines,[existingDefines;discardDefines],'stable');


    definesToCopy=[];

    if~any(strcmp(existingDefines,'NRT'))





        mexIdx=find(strcmp(modelDefines,'MATLAB_MEX_FILE'));
        rtIdx=find(strcmp(modelDefines,'RT'));
        if~isempty(mexIdx)
            nrtIdx=mexIdx;
            assert(isempty(rtIdx),'Build must not define both RT and MATLAB_MEX_FILE')
        elseif~isempty(rtIdx)
            nrtIdx=rtIdx;
        else
            nrtIdx=[];
        end

        if~isempty(nrtIdx)
            defMATLAB_MEX_FILE=RTW.BuildInfoKeyValuePair;
            defMATLAB_MEX_FILE.Key='NRT';
            defMATLAB_MEX_FILE.DisplayLabel='NRT';
            defMATLAB_MEX_FILE.Group=donorBuildInfo.Options.Defines(nrtIdx).Group;
            definesToCopy=defMATLAB_MEX_FILE;
        end
    end
    if~isempty(definesToCopy)||~isempty(copyIdx)
        definesToCopy=[definesToCopy;donorBuildInfo.Options.Defines(copyIdx)];
        if isempty(recipientBuildInfo.Options.Defines)
            recipientBuildInfo.Options.Defines=definesToCopy;
        else
            recipientBuildInfo.Options.Defines=...
            [recipientBuildInfo.Options.Defines;definesToCopy];
        end
        recipientBuildInfoIsUpToDate=false;
    end




    mutexFlags={'/Od','/O2'};


    [lCompileFlagsValues,lCompileFlagsGroups]=...
    i_get(donorBuildInfo.Options.CompileFlags);
    lCompileFlagsExistingValues=i_get(recipientBuildInfo.Options.CompileFlags);

    if~isempty(intersect(lCompileFlagsExistingValues,mutexFlags))

        lCompileFlagsExistingValues=union(lCompileFlagsExistingValues,mutexFlags);
    end

    [~,newIdx]=setdiff(lCompileFlagsValues,lCompileFlagsExistingValues,'stable');
    lCompileFlagsNewValues=lCompileFlagsValues(newIdx);
    if~isempty(lCompileFlagsNewValues)
        lCompileFlagsNewGroups=lCompileFlagsGroups(newIdx);
        addCompileFlags(recipientBuildInfo,lCompileFlagsNewValues,...
        lCompileFlagsNewGroups);
        recipientBuildInfoIsUpToDate=false;
    end


    [lLinkFlagsValues,lLinkFlagsGroups]=i_get(donorBuildInfo.Options.LinkFlags);
    lLinkFlagsExistingValues=i_get(recipientBuildInfo.Options.LinkFlags);
    [~,newIdx]=setdiff(lLinkFlagsValues,lLinkFlagsExistingValues,'stable');
    lLinkFlagsNewValues=lLinkFlagsValues(newIdx);
    if~isempty(lLinkFlagsNewValues)
        lLinkFlagsNewGroups=lLinkFlagsGroups(newIdx);
        addLinkFlags(recipientBuildInfo,lLinkFlagsNewValues,lLinkFlagsNewGroups);
        recipientBuildInfoIsUpToDate=false;
    end


    [lArchiveFlagsValues,lArchiveFlagsGroups]=i_get(donorBuildInfo.Options.ArchiveFlags);
    lArchiveFlagsExistingValues=i_get(recipientBuildInfo.Options.ArchiveFlags);
    [~,newIdx]=setdiff(lArchiveFlagsValues,lArchiveFlagsExistingValues,'stable');
    lArchiveFlagsNewValues=lArchiveFlagsValues(newIdx);
    if~isempty(lArchiveFlagsNewValues)
        lArchiveFlagsNewGroups=lArchiveFlagsGroups(newIdx);
        addArchiveFlag(recipientBuildInfo,lArchiveFlagsNewValues,lArchiveFlagsNewGroups);
        recipientBuildInfoIsUpToDate=false;
    end




    discardArgs={
'COMBINE_OUTPUT_UPDATE_FCNS'
'DEFAULT_BUILD_VARIANT_FOR_PACKNGO'
'DEFAULT_TOOLCHAIN_FOR_PACKNGO'
'EXTMODE_STATIC_ALLOC'
'EXTMODE_STATIC_ALLOC_SIZE'
'EXTMODE_TRANSPORT'
'EXT_MODE'
'GENERATE_ASAP2'
'GENERATE_ERT_S_FUNCTION'
'INCLUDE_MDL_TERMINATE_FCN'
'INTEGER_CODE'
'ISPROTECTINGMODEL'
'MAT_FILE'
'MODELLIB'
'MODELREF_TARGET_TYPE'
'MULTI_INSTANCE_CODE'
'RELATIVE_PATH_TO_ANCHOR'
'SHARED_SRC_DIR'
'STANDALONE_SUPPRESS_EXE'
'TMW_EXTMODE_TESTING'
    };


    if isempty(donorBuildInfo.BuildArgs)
        lBuildArgKeysModel={};
    else
        lBuildArgKeysModel={donorBuildInfo.BuildArgs.Key};
    end
    if isempty(recipientBuildInfo.BuildArgs)
        lBuildArgKeysExisting={};
    else
        lBuildArgKeysExisting={recipientBuildInfo.BuildArgs.Key};
    end
    [~,newBuildArgsIdx]=...
    setdiff(lBuildArgKeysModel,[lBuildArgKeysExisting(:);discardArgs(:)],'stable');
    if~isempty(newBuildArgsIdx)
        recipientBuildInfo.BuildArgs=[recipientBuildInfo.BuildArgs
        donorBuildInfo.BuildArgs(newBuildArgsIdx)];
        recipientBuildInfoIsUpToDate=false;
    end


    discardTokens={'|>MODEL_NAME<|','|>MAKEFILE_NAME<|'};

    if isempty(donorBuildInfo.Tokens)
        lTMFToksModel={};
    else
        lTMFToksModel={donorBuildInfo.Tokens.Key};
    end
    if isempty(recipientBuildInfo.Tokens)
        lTMFToksExisting={};
    else
        lTMFToksExisting={recipientBuildInfo.Tokens.Key};
    end
    [~,newToksIdx]=...
    setdiff(lTMFToksModel,[lTMFToksExisting(:);discardTokens(:)],'stable');
    if~isempty(newToksIdx)
        recipientBuildInfo.Tokens=[recipientBuildInfo.Tokens
        donorBuildInfo.Tokens(newToksIdx)];
        recipientBuildInfoIsUpToDate=false;
    end


    function[values,groups]=i_get(obj)

        values=get(obj,'Value');
        groups=get(obj,'Group');
        if isempty(values)
            values={};
            groups={};
        elseif~iscell(values)
            values={values};
            groups={groups};
        end
