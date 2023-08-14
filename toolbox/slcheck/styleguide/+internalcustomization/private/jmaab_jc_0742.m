function jmaab_jc_0742










    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0742');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0742_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0742';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(...
    system,checkObj,'ModelAdvisor:jmaab:jc_0742',@hCheckAlgo),'None','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0742_tip');
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([4,4]);

    inputParamList{1}=ModelAdvisor.InputParameter;
    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:jc_0742_operatorsPerLine');
    inputParamList{end}.Type='Number';
    inputParamList{end}.Value=getOptionsConditionsPerLine;
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Visible=false;

    inputParamList{end+1}=ModelAdvisor.InputParameter;

    inputParamList{end}.Name=DAStudio.message('ModelAdvisor:jmaab:jc_0742_logicalOperations');
    inputParamList{end}.Type='Bool';
    inputParamList{end}.Value=false;
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Visible=false;

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[3,3];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[3,3];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,sg_jmaab_group);
end



function default=getOptionsConditionsPerLine
    default='3';
end


function FailingObjs=hCheckAlgo(system)
    FailingObjs=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ip=mdlAdvObj.getInputParameterByName(DAStudio.message('ModelAdvisor:jmaab:jc_0742_logicalOperations'));
    logicalOperationsCondition=ip.Value;
    conditionsAllowedPerLine=str2double(mdlAdvObj.getInputParameterByName(...
    DAStudio.message('ModelAdvisor:jmaab:jc_0742_operatorsPerLine')).Value);

    flv=mdlAdvObj.getInputParameterByName('Follow links');
    lum=mdlAdvObj.getInputParameterByName('Look under masks');



    sfCharts=mdlAdvObj.filterResultWithExclusion(...
    Advisor.Utils.Stateflow.sfFindSys(system,flv.Value,lum.Value,{'-isa','Stateflow.Chart'}));

    if isempty(sfCharts)
        return;
    end

    for k=1:length(sfCharts)
        variableNames=getVariableNames(sfCharts{k});
        sfTransitions=sfCharts{k}.find('-isa','Stateflow.Transition');

        for index=1:length(sfTransitions)
            label=sfTransitions(index).LabelString;
            if isempty(label)
                continue;
            end

            if logicalOperationsCondition

                if~isLogicalExpressionsAcceptable(label,variableNames,sfCharts{k}.EnableBitOps)
                    tempFailObj=ModelAdvisor.internal.prepareFailureObject(sfTransitions(index),...
                    DAStudio.message('ModelAdvisor:jmaab:jc_0742_rec_action_LogicalExpressions'),...
                    DAStudio.message('ModelAdvisor:jmaab:jc_0742_warn_LogicalExpressions'));
                    FailingObjs=[FailingObjs,tempFailObj];%#ok<AGROW>
                end
            end

            if~sfCharts{k}.EnableBitOps


                label=modifyBitwiseAndOr(label);
            end

            if~isConditionsPerLineAcceptable(label,conditionsAllowedPerLine)
                tempFailObj=ModelAdvisor.internal.prepareFailureObject(sfTransitions(index),...
                DAStudio.message('ModelAdvisor:jmaab:jc_0742_rec_action_ConditionsPerLine'),...
                DAStudio.message('ModelAdvisor:jmaab:jc_0742_warn_ConditionsPerLine'));
                FailingObjs=[FailingObjs,tempFailObj];%#ok<AGROW>
            end
            if~isMixedOperatorsParenthesisAcceptable(label)
                tempFailObj=ModelAdvisor.internal.prepareFailureObject(sfTransitions(index),...
                DAStudio.message('ModelAdvisor:jmaab:jc_0742_rec_action_MixedOperators'),...
                DAStudio.message('ModelAdvisor:jmaab:jc_0742_warn_MixedOperators'));
                FailingObjs=[FailingObjs,tempFailObj];%#ok<AGROW>
            end
            if~isOperatorPositionsUnified(label)
                tempFailObj=ModelAdvisor.internal.prepareFailureObject(sfTransitions(index),...
                DAStudio.message('ModelAdvisor:jmaab:jc_0742_rec_action_OperatorPositions'),...
                DAStudio.message('ModelAdvisor:jmaab:jc_0742_warn_OperatorPositions'));
                FailingObjs=[FailingObjs,tempFailObj];%#ok<AGROW>
            end
        end
    end
end



function variableNames=getVariableNames(chart)
    sfData=chart.find('-isa','Stateflow.Data');
    names=arrayfun(@(x)x.Name,sfData,'UniformOutput',false);
    variableNames=names(arrayfun(@(x)~strcmp(x.DataType,'boolean'),sfData));
end





function result=isConditionsPerLineAcceptable(str,numConditions)
    result=ModelAdvisor.internal.styleguide_jmaab_0742_conditionsPerLine(str,numConditions);
end








function result=isMixedOperatorsParenthesisAcceptable(str)
    result=ModelAdvisor.internal.styleguide_jmaab_0742_mixedOperators(str);
end



function result=isOperatorPositionsUnified(str)
    result=ModelAdvisor.internal.styleguide_jmaab_0742_unifiedPosition(str);
end


function result=isLogicalExpressionsAcceptable(str,captureGroup,enableBit)
    result=ModelAdvisor.internal.styleguide_jmaab_0742_logicalExpressions(str,captureGroup,enableBit);
end




function str=modifyBitwiseAndOr(str)
    str=regexprep(str,'(?<!&)&(?!&)','&&');
    str=regexprep(str,'(?<!\|)\|(?!\|)','||');
end
