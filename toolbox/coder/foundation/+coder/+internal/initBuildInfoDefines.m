function initBuildInfoDefines...
    (lBuildInfo,buildArgsAsCellArray,lExtMode,lExtModeStaticAlloc,...
    lExtModeTesting,lCodeFormat,lMultiTasking,lModelReferenceTargetType,...
    lNeedSolverSources,lPurelyIntegerCode)




    bArgs=regexprep(buildArgsAsCellArray,'^([^=]+)=.*','$1');
    bArgVals=regexprep(buildArgsAsCellArray,'^[^=]+=?(.*)$','$1');



    bArgsAsDefines={'INCLUDE_MDL_TERMINATE_FCN',...
    'COMBINE_OUTPUT_UPDATE_FCNS',...
    'MAT_FILE',...
    'MULTI_INSTANCE_CODE'};


    if strcmp('on',lExtMode)
        bArgsAsDefines{end+1}='EXT_MODE';

        if lExtModeStaticAlloc
            bArgsAsDefines{end+1}='EXT_STATIC';
            bArgsAsDefines{end+1}='EXT_STATIC_SIZE';
        end
        if lExtModeTesting
            bArgsAsDefines{end+1}='TMW_EXTMODE_TESTING';
        end
    end

    [~,bDefsIdx]=intersect(bArgs,bArgsAsDefines,'stable');

    bDefs=strcat(bArgs(bDefsIdx),'=',bArgVals(bDefsIdx));



    bDefs=strrep(bDefs,'INCLUDE_MDL_TERMINATE_FCN','TERMFCN');
    bDefs=strrep(bDefs,'COMBINE_OUTPUT_UPDATE_FCNS','ONESTEPFCN');



    bDefs=[bDefs,['INTEGER_CODE=',sprintf('%d',lPurelyIntegerCode)]];

    if(~strcmp(lModelReferenceTargetType,'SIM')&&...
        ~strcmp(lCodeFormat,'Accelerator_S-Function'))

        if lNeedSolverSources
            bDefs=[bDefs,['MT=',lMultiTasking]];
        end
    end

    lBuildInfo.addDefines(bDefs,'Build Args');
