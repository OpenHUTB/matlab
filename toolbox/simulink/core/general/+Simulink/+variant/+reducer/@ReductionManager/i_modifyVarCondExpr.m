






function isCondModified=i_modifyVarCondExpr(optArgs,varBlockPath,enumForModCond,varargin)


    narginchk(3,5);



    isCondModified=false;


    ctrlVarsUsedInBlk=Simulink.variant.utils.getControlVariableNamesFromVariantExpressions(varBlockPath);


    allConfigCond=i_getAllConfigCond(optArgs.ProcessedModelInfoStructsVec(1).ConfigInfos,ctrlVarsUsedInBlk);

    if isempty(optArgs.FullRangeAnalysisInfo)
        fullRangeConditionsMap=containers.Map;
    else
        fullRangeConditionsMap=optArgs.FullRangeAnalysisInfo.FullRangeConditionsMap;
    end

    if isempty(allConfigCond)&&~fullRangeConditionsMap.isKey(varBlockPath)
        return;
    end

    if enumForModCond.isVariantSource||enumForModCond.isVariantSink
        variantsParam=i_mat2cell(get_param(varBlockPath,'VariantControls'));
        newVariantsParam=variantsParam;
        for varBlkChoice=1:numel(variantsParam)
            [modVarCond,skipCondModification]=i_getModCondForVarBlk(...
            varBlockPath,variantsParam{varBlkChoice},allConfigCond,fullRangeConditionsMap);
            if~skipCondModification
                isCondModified=true;
                newVariantsParam{varBlkChoice}=modVarCond;
            end
        end


        if isCondModified
            set_param(varBlockPath,'VariantControls',newVariantsParam);
        end
    elseif enumForModCond.isVariantSubsystem
        variantsParam=get_param(varBlockPath,'Variants');
        for blkChoice=1:numel(variantsParam)
            [modVarCond,skipCondModification]=i_getModCondForVarBlk(...
            varBlockPath,variantsParam(blkChoice).Name,allConfigCond,fullRangeConditionsMap);
            if~skipCondModification
                isCondModified=true;
                set_param(variantsParam(blkChoice).BlockName,'VariantControl',modVarCond);
            end


        end
    elseif enumForModCond.isModelVariant
        variantsParam=get_param(varBlockPath,'Variants');
        newVariantsParam=variantsParam;


        for varBlkChoice=1:numel(variantsParam)
            [modVarCond,skipCondModification]=i_getModCondForVarBlk(...
            varBlockPath,variantsParam(varBlkChoice).Name,allConfigCond,fullRangeConditionsMap);
            if~skipCondModification
                isCondModified=true;
                newVariantsParam(varBlkChoice).Name=modVarCond;
            end
        end
        if isCondModified

            set_param(varBlockPath,'Variants',newVariantsParam);
        end
    elseif enumForModCond.isVariantSimulinkFunction||enumForModCond.isVariantIRTSubsystem
        Simulink.variant.reducer.utils.assert(nargin==5);


        portBlk=varargin{1};
        blkCond=varargin{2};
        [modVarCond,skipCondModification]=i_getModCondForVarBlk(varBlockPath,blkCond,allConfigCond,fullRangeConditionsMap);
        if~skipCondModification
            isCondModified=true;
            set_param(portBlk,'VariantControl',modVarCond);
        end
    end
end



function[modVarCond,skipCondModification]=i_getModCondForVarBlk(varBlockPath,origVarCond,allConfigCond,fullRangeConditionsMap)














































    nargoutchk(2,2)
    modVarCond=origVarCond;
    skipCondModification=false;
    try
        modVarCond=strtrim(modVarCond);




        if Simulink.variant.utils.existsVarOfTypeInSourceWSOf(i_getRootBDNameFromPath(varBlockPath),modVarCond,'Simulink.Variant')
            return;
        end


        isSingleChoiceVarSrcSinkBlock=any(strcmp(get_param(varBlockPath,'BlockType'),{'VariantSource','VariantSink'}))&&(numel(get_param(varBlockPath,'VariantControls'))==1);
        isDefaultChoiceWithMultipleActiveChoices=strcmp(origVarCond,'(default)')&&~isSingleChoiceVarSrcSinkBlock;
        if isDefaultChoiceWithMultipleActiveChoices||strcmp(origVarCond(1),'%')

            return;
        end



        if fullRangeConditionsMap.isKey(varBlockPath)
            ConditionsToModifyInfoMap=fullRangeConditionsMap(varBlockPath);
            if ConditionsToModifyInfoMap.isKey(origVarCond)
                modVarCond=ConditionsToModifyInfoMap(origVarCond);
            end
        else


            modVarCond=slInternal('SimplifyVarCondExpr',['(',origVarCond,')',' && ','(',allConfigCond,')']);
        end
    catch me %#ok<NASGU>







    end

    if strcmp(strrep(modVarCond,' ',''),strrep(origVarCond,' ',''))

        skipCondModification=true;
    end
end


