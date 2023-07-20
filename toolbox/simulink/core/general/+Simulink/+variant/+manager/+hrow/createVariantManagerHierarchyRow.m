function parentNode=createVariantManagerHierarchyRow(modelName,parentRow,blockPath,createModelInfoArgs,vmBlockType)




    fullNameToRowMap=createModelInfoArgs.FullNameToRowMap;
    rowArgsStruct=Simulink.variant.manager.hrow.initializeCreateRowArgsStruct();

    blockName=Simulink.variant.utils.getNameFromRenderedName(get_param(blockPath,'Name'));
    rowArgsStruct.RootModelOrBlockName=blockName;
    rowArgsStruct.VMBlockType=vmBlockType;

    if fullNameToRowMap.isKey(blockPath)


        parentNode=fullNameToRowMap(blockPath);
        parentNode.setVMBlockType(vmBlockType);
    else
        parentNode=Simulink.variant.manager.hrow.createRow(parentRow,rowArgsStruct,blockPath);
        fullNameToRowMap(blockPath)=parentNode;
    end





    if isequal(rowArgsStruct.VMBlockType,Simulink.variant.manager.VariantManagerBlockType.ModelReference)&&...
        ~parentNode.getIsOrInsideIgnoredBranch()

        mdlRefBlocksData=createModelInfoArgs.MdlRefBlocksData;
        blockPathInModelWithoutModelName=blockPath(length(modelName)+2:end);
        if isempty(createModelInfoArgs.RootPathPrefix)
            rootPathPrefix=[modelName,'/',blockPathInModelWithoutModelName];
        else
            rootPathPrefix=[createModelInfoArgs.RootPathPrefix,'/',blockPathInModelWithoutModelName];
        end
        createModelInfoArgs.MdlRefBlocksData=Simulink.variant.manager.hrow.updateModelRefsData(blockPath,rootPathPrefix,mdlRefBlocksData);
    end

    if Simulink.variant.manager.VariantManagerBlockType.getIsNonVariantBlock(vmBlockType)

        return;
    end

    oldIgnoreErrorsFlag=createModelInfoArgs.IgnoreErrors;
    createModelInfoArgs.IgnoreErrors=oldIgnoreErrorsFlag||parentNode.getIsOrInsideIgnoredBranch();

    function errFlagCleanupFcn(createModelInfoArgs,oldIgnoreErrorsFlag)
        createModelInfoArgs.IgnoreErrors=oldIgnoreErrorsFlag;
    end
    errFlagCleanup=onCleanup(@()errFlagCleanupFcn(createModelInfoArgs,oldIgnoreErrorsFlag));

    infoFromCSide=Simulink.variant.utils.getVariantBlockInfoForVM(blockPath,createModelInfoArgs);

    variantError=infoFromCSide(1).Errors;
    if createModelInfoArgs.IgnoreErrors||isempty(variantError)
        variantErrorStr='';
    else
        variantError=pickFirstError_g1807861(variantError);
        variantErrorStr=Simulink.variant.utils.i_convertMExceptionHierarchyToMessage(variantError);
    end
    rootPathPrefix=createModelInfoArgs.RootPathPrefix;
    varBlockPathFromRoot=Simulink.variant.utils.getBlockPathRootModel(blockPath,rootPathPrefix);
    parentNode.setVariantProperties(infoFromCSide(1).ValidationResultType,variantErrorStr);

    errors=Simulink.variant.manager.errorutils.ValidationError.empty;


    if~isempty(variantErrorStr)


        errors(end+1)=Simulink.variant.manager.errorutils.ValidationError(...
        blockPath,varBlockPathFromRoot,variantError(1));
    end

    if~isempty(infoFromCSide(1).BlockParameters)
        parentNode.setBlockParamInfo(infoFromCSide(1).BlockParameters);
    end

    rowArgsStruct=Simulink.variant.manager.hrow.initializeCreateRowArgsStruct();
    numRowsFromCSide=length(infoFromCSide);


    for i=2:numRowsFromCSide
        childRowFromCSide=infoFromCSide(i);
        rowArgsStruct.RootModelOrBlockName=childRowFromCSide.Name;

        rowArgsStruct.VMBlockType=[];
        choiceBlockPath=[blockPath,'/',childRowFromCSide.Name];

        choiceError=childRowFromCSide.Errors;
        if~isempty(choiceError)



            varChoiceName=rowArgsStruct.RootModelOrBlockName;
            pathInModel=[blockPath,'/',varChoiceName];
            pathFromRoot=[varBlockPathFromRoot,'/',varChoiceName];
            choiceError=pickFirstError_g1807861(choiceError);
            errors(end+1)=Simulink.variant.manager.errorutils.ValidationError(pathInModel,pathFromRoot,choiceError);%#ok<AGROW>
        end

        choiceRowErrStr='';
        if~isempty(choiceError)
            choiceRowErrStr=Simulink.variant.utils.i_convertMExceptionHierarchyToMessage(choiceError);
        end

        rowArgsStruct.VariantChoiceInformation=Simulink.internal.vmgr.VariantChoiceInformation(...
        childRowFromCSide.VarControl,childRowFromCSide.VarCondition,childRowFromCSide.IsVariantControlSimulinkVariantObject,...
        childRowFromCSide.ValidationResultType,choiceRowErrStr);


        childRow=Simulink.variant.manager.hrow.createRow(parentNode,rowArgsStruct,choiceBlockPath);
        ioRowKey=[blockPath,'/',childRowFromCSide.Name];
        fullNameToRowMap(ioRowKey)=childRow;
    end

    createModelInfoArgs.ErrorLog=[createModelInfoArgs.ErrorLog,errors];
end


function err=pickFirstError_g1807861(errs)


    err=errs(1);

    if numel(errs)>1
        return;
    end

    if~strcmp(errs.identifier,'MATLAB:MException:MultipleErrors')
        return;
    end

    if numel(errs.cause)>=1
        err=errs.cause{1};
    end

end


