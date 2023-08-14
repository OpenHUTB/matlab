function[ranges,hasDefaultChoice,trueChoiceCount,errors]=ControlVarRangeFactory(topModelName,blockPathParentModel,variants,isAZVCOn,specifiedVariableConfigAndAnalysisInfo)



    ranges=[];
    errors=[];
    values={};
    hasDefaultChoice=false;
    defaultCaseCount=0;
    trueChoiceCount=0;
    unsupportedExpressions={};
    origCondSimplifiedCondMap=containers.Map;

    if isfield(specifiedVariableConfigAndAnalysisInfo,'SpecialVarsInfoManager')

        specialVarsInfoManager=specifiedVariableConfigAndAnalysisInfo.SpecialVarsInfoManager;
    else

        parentModelName=bdroot(blockPathParentModel);
        if~specifiedVariableConfigAndAnalysisInfo.SpecialVarsInfoManageMap.isKey(parentModelName)
            specialVarsInfoManager=Simulink.variant.manager.SpecialVarsInfoManager(parentModelName);
            specifiedVariableConfigAndAnalysisInfo.SpecialVarsInfoManageMap(parentModelName)=specialVarsInfoManager;
        else
            specialVarsInfoManager=specifiedVariableConfigAndAnalysisInfo.SpecialVarsInfoManageMap(parentModelName);
        end
    end

    for i=1:numel(variants)
        origExpr=variants{i};
        expr=origExpr;
        isDefaultExpr=(numel(regexp(expr,'(default)'))==1);
        if isDefaultExpr
            defaultCaseCount=defaultCaseCount+1;
            continue;
        end

        if isvarname(expr)
            if specialVarsInfoManager.getIsSimulinkVariantObject(expr)


                expr=specialVarsInfoManager.getConditionIfSimulinkVariant(expr);
            elseif~Simulink.variant.utils.isTrueFalseLiteral(expr)
                err=MException(message('Simulink:Variants:VariantConditionNotVariantObject',expr,blockPathParentModel));
                errors=[errors,err];%#ok<AGROW>
                continue;
            end
        end

        isIgnoredCondition=isempty(expr);
        isCommentedCondition=~isIgnoredCondition&&(expr(1)=='%');

        if isIgnoredCondition||isCommentedCondition
            if any(strcmp(get_param(blockPathParentModel,'BlockType'),{'VariantSink','VariantSource'}))
                if isCommentedCondition


                    err=MException(message('Simulink:Variants:ErrorInEvalOfBeginningOfVarControl',blockPathParentModel,expr));
                    errors=[errors,err];%#ok<AGROW>
                    continue;
                end
            else


                continue;
            end
        end

        expr=Simulink.variant.utils.replaceSimulinkVariantObjectsWithExpressions(topModelName,expr,specialVarsInfoManager,{},true);
        expr=Simulink.variant.reducer.fullrange.FullRangeManager.applySpecifiedConfigAndSimplifyExpression(...
        expr,specifiedVariableConfigAndAnalysisInfo.SpecifiedVariableConfiguration);
        origCondSimplifiedCondMap(origExpr)=struct('SimplifiedCond',expr);

        isFalseExpr=strcmp(expr,'false');
        if isFalseExpr
            continue;
        end

        isTrueChoice=strcmp(expr,'true');
        if isTrueChoice
            trueChoiceCount=trueChoiceCount+1;
        end

        isEqualExpr=~isTrueChoice&&(numel(regexp(expr,'=='))==1)&&isempty(regexp(expr,'~=','once'));
        isInequalExpr=~isTrueChoice&&(numel(regexp(expr,'~='))==1)&&isempty(regexp(expr,'==','once'));

        NameAndValuePair={};
        if isEqualExpr
            NameAndValuePair=strsplit(expr,'==');
        elseif isInequalExpr
            NameAndValuePair=strsplit(expr,'~=');
        end

        for j=1:numel(NameAndValuePair)
            NameAndValuePair{j}=strtrim(NameAndValuePair{j});%#ok<AGROW>
        end

        isSupportedExpression=isTrueChoice||xor(isEqualExpr,isInequalExpr)&&(numel(NameAndValuePair)==2)&&...
        any(strcmp(specifiedVariableConfigAndAnalysisInfo.FullRangeCtrlVarName,NameAndValuePair));

        if isTrueChoice

            value='';
        elseif isSupportedExpression

            NameAndValuePair(strcmp(NameAndValuePair,specifiedVariableConfigAndAnalysisInfo.FullRangeCtrlVarName))=[];%#ok<AGROW>
            value=NameAndValuePair{1};
            dotIdxs=regexp(value,'\.');
            if numel(dotIdxs)==1


                value=num2str(double(eval(value)));
            end
            isSupportedExpression=~isempty(str2num(value));%#ok<ST2NM>
        end

        if~isSupportedExpression
            unsupportedExpressions{end+1}=origExpr;%#ok<AGROW>
            continue;
        end

        values=[values;struct('Value',str2num(value),...
        'IsEqualExpr',isEqualExpr,...
        'IsInequalExpr',isInequalExpr,...
        'IsTrueChoice',isTrueChoice,...
        'OrigExpr',origExpr)];%#ok<ST2NM,AGROW>
    end

    if numel(unsupportedExpressions)>0
        unsupportedExpressionsStr='';
        for i=1:numel(unsupportedExpressions)
            unsupportedExpressionsStr=[unsupportedExpressionsStr,newline,unsupportedExpressions{i}];%#ok<AGROW>
        end
        err=MException(message('Simulink:VariantReducer:FullRangeNotFirstOrderExpression',blockPathParentModel,specifiedVariableConfigAndAnalysisInfo.FullRangeCtrlVarName,unsupportedExpressionsStr));
        errors=[errors,err];
    end

    if defaultCaseCount>1
        if any(strcmp(get_param(blockPathParentModel,'BlockType'),{'VariantSink','VariantSource'}))


            if strcmp(get_param(blockPathParentModel,'BlockType'),'VariantSource')
                blockNameMsg=getString(message('Simulink:Variants:VarSrc'));
            else
                blockNameMsg=getString(message('Simulink:Variants:VarSink'));
            end
            err=MException(message('Simulink:Variants:InlineVariantWithMultipleDefaultPorts',blockNameMsg,blockPathParentModel));
        elseif(strcmp(get_param(blockPathParentModel,'BlockType'),'SubSystem'))


            err=MException(message('Simulink:blocks:VariantMultipleDefaultVariants',blockPathParentModel,blockPathParentModel));
        end
        errors=[errors,err];
    end

    if trueChoiceCount>1
        err=MException(message('Simulink:VariantReducer:FullRangeMultipleActiveChoice',...
        blockPathParentModel,i_convertSpecifiedVariableConfigurationToStr(specifiedVariableConfigAndAnalysisInfo.SpecifiedVariableConfiguration)));
        errors=[errors,err];
    end

    if~isempty(errors)
        return;
    end

    blockPathParentModelForCondModification=specifiedVariableConfigAndAnalysisInfo.BlockPathParentModelForCondModification;
    for i=1:numel(values)
        equalityValues=[];inequalityValues=[];
        if values{i,1}.IsEqualExpr
            equalityValues=values{i,1}.Value;
        elseif values{i,1}.IsInequalExpr
            inequalityValues=values{i,1}.Value;
        end
        controlVarRange=Simulink.variant.reducer.fullrange.ControlVarRange(blockPathParentModel,blockPathParentModelForCondModification,equalityValues,inequalityValues,false,values{i,1}.IsTrueChoice,values{i,1}.OrigExpr);
        ranges=[ranges,controlVarRange];%#ok<AGROW>
    end

    hasDefaultChoice=(defaultCaseCount>0);
    if(trueChoiceCount==0)&&(hasDefaultChoice||isAZVCOn)


        allEqualityValues=[];allInequalityValues=[];
        for i=1:numel(values)
            if values{i,1}.IsInequalExpr
                allEqualityValues=[allEqualityValues,values{i,1}.Value];%#ok<AGROW>
            elseif values{i,1}.IsEqualExpr
                allInequalityValues=[allInequalityValues,values{i,1}.Value];%#ok<AGROW>
            end
        end

        if hasDefaultChoice
            origExpr='(default)';
        else
            origExpr='';
        end
        controlVarRange=Simulink.variant.reducer.fullrange.ControlVarRange(blockPathParentModel,blockPathParentModelForCondModification,unique(allEqualityValues),unique(allInequalityValues),true,false,origExpr);
        ranges=[ranges,controlVarRange];
    end
end

function str=i_convertSpecifiedVariableConfigurationToStr(specifiedVariableConfiguration)
    str=Simulink.variant.reducer.fullrange.FullRangeManager.convertSpecifiedVariableConfigurationToStr(specifiedVariableConfiguration);
end


