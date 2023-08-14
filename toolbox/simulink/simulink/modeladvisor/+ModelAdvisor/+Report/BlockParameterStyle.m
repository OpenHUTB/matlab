classdef BlockParameterStyle<ModelAdvisor.Report.CheckStyleFactory




    methods
        function obj=BlockParameterStyle
            obj.Name=getString(message('ModelAdvisor:engine:RecommendedAction'));
        end

        function html=generateReport(~,CheckObj)
            if isa(CheckObj,'ModelAdvisor.Task')
                CheckObj=CheckObj.Check;
            end
            elementsObj=CheckObj.ResultDetails;
            fts=ModelAdvisor.Report.BlockParameterStyle.sort(elementsObj,'RecommendedAction');
            fts=ModelAdvisor.Report.Utils.removeTrailingSubbar(fts);
            html=fts;
        end

    end

    methods(Static)

        function fts=sort(elementsObj,~)
            fts={};
            templateMap=containers.Map;

            for i=1:length(elementsObj)

                if strcmp(elementsObj(i).ViolationType,'Warning')

                    if~isa(elementsObj(i).DetailedInfo,'ModelAdvisor.BlockParameter')
                        error(message('ModelAdvisor:engine:MABlockParamStyleError2'));
                    end

                    if elementsObj(i).DetailedInfo.operatorType==ModelAdvisor.OperatorType.TYPE

                        if templateMap.isKey(elementsObj(i).RecAction)
                            ft=templateMap(elementsObj(i).RecAction);
                        else
                            ft=getFormatTemplate(elementsObj(i),'ListTemplate');
                            templateMap(elementsObj(i).RecAction)=ft;
                        end
                        block=getBlockInformation(elementsObj(i));
                        violatedBlocks=ft.ListObj;
                        violatedBlocks{end+1}=block;
                        ft.setListObj(violatedBlocks)

                    else

                        if templateMap.isKey(elementsObj(i).RecAction)
                            ft=templateMap(elementsObj(i).RecAction);
                        else
                            ft=getFormatTemplate(elementsObj(i),'TableTemplate');
                            ft.setColTitles({...
                            getString(message('ModelAdvisor:engine:Block')),...
                            getString(message('Advisor:engine:Parameter')),...
                            getString(message('Advisor:engine:CurrentValue')),...
                            getString(message('Advisor:engine:RecValues'))});

                            templateMap(elementsObj(i).RecAction)=ft;
                        end

                        block=getBlockInformation(elementsObj(i));
                        blockParamLink=Advisor.Utils.getHyperlinkToBlockParameter(block,elementsObj(i).DetailedInfo.Parameter);
                        CurrentValue=getCurrentValue(elementsObj(i));
                        RecommendedValue=getRecommendedValue(elementsObj(i));
                        ft.addRow({block,blockParamLink,CurrentValue,RecommendedValue});

                    end
                else
                    ft=getFormatTemplate(elementsObj(i),'ListTemplate');
                    templateMap(elementsObj(i).ViolationType)=ft;
                end
            end

            templates=templateMap.values;

            for count=1:numel(templates)
                fts(end+1)=templates(count);
            end
        end
    end
end

function block=getBlockInformation(resulDetail)
    if~isempty(resulDetail.Data)
        block=resulDetail.Data;
    elseif~isempty(resulDetail.DetailedInfo.Block)
        block=resulDetail.DetailedInfo.Block;
    else
        error(message('ModelAdvisor:engine:MABlockParamStyleError1'));
    end
end

function CurrentValue=getCurrentValue(result)
    CurrentValue=result.DetailedInfo.currentValue;
    CurrentValue=CurrentValue.toArray;
    if isempty(CurrentValue)
        error(message('ModelAdvisor:engine:MABlockParamStyleError3'));
    end
    CurrentValue=CurrentValue{1};

end

function RecommendedValue=getRecommendedValue(result)
    blockParamViolation=result.DetailedInfo;
    RecommendedValue=result.DetailedInfo.fixValue;
    RecommendedValue=RecommendedValue.toArray;

    if isempty(RecommendedValue)
        error(message('ModelAdvisor:engine:MABlockParamStyleError4'));
    end

    if isempty(blockParamViolation.operatorType)
        RecommendedValue=RecommendedValue{1};
    else
        RecommendedValue=recommendedValueForBlockConstraint(blockParamViolation,RecommendedValue);
    end

end

function ft=getFormatTemplate(result,templateType)
    ft=ModelAdvisor.FormatTemplate(templateType);
    ft=ModelAdvisor.Report.Utils.processBasicData(result,ft,...
    {'Description','Title','Information','Status','RecAction'});
end

function recommendedValue=recommendedValueForBlockConstraint(blockParamViolation,values)
    if blockParamViolation.operatorType==ModelAdvisor.OperatorType.EQ
        msgCatalogue='edittimecheck:engine:MABlockParameterConstraintRecommendedValueEQ';
    elseif blockParamViolation.operatorType==ModelAdvisor.OperatorType.LT
        msgCatalogue='edittimecheck:engine:MABlockParameterConstraintRecommendedValueLT';
    elseif blockParamViolation.operatorType==ModelAdvisor.OperatorType.GT
        msgCatalogue='edittimecheck:engine:MABlockParameterConstraintRecommendedValueGT';
    elseif blockParamViolation.operatorType==ModelAdvisor.OperatorType.LE
        msgCatalogue='edittimecheck:engine:MABlockParameterConstraintRecommendedValueLE';
    elseif blockParamViolation.operatorType==ModelAdvisor.OperatorType.GE
        msgCatalogue='edittimecheck:engine:MABlockParameterConstraintRecommendedValueGE';
    elseif blockParamViolation.operatorType==ModelAdvisor.OperatorType.OR
        msgCatalogue='edittimecheck:engine:MABlockParameterConstraintRecommendedValueEQOR';
    elseif blockParamViolation.operatorType==ModelAdvisor.OperatorType.RANGE
        msgCatalogue='edittimecheck:engine:MABlockParameterConstraintRecommendedValueRANGE';
    elseif blockParamViolation.operatorType==ModelAdvisor.OperatorType.REGEX
        msgCatalogue='edittimecheck:engine:MABlockParameterConstraintRecommendedValueREGEX';
    elseif blockParamViolation.operatorType==ModelAdvisor.OperatorType.TYPE
        msgCatalogue='edittimecheck:engine:MABlockTypeConstraintRecommendedValue';
    else
        error(message('edittimecheck:engine:UnknownBlockConstraintType'));
    end

    if blockParamViolation.signType==ModelAdvisor.Sign.NEGATIVE
        msgCatalogue=[msgCatalogue,'N'];
    end
    if any(strcmp(msgCatalogue,...
        {'edittimecheck:engine:MABlockParameterConstraintRecommendedValueRANGE',...
        'edittimecheck:engine:MABlockParameterConstraintRecommendedValueRANGEN'}))
        recommendedValue=getString(message(msgCatalogue,values{1},values{2}));
    else
        recommendedValue=getString(message(msgCatalogue,values{1}));
    end

end
