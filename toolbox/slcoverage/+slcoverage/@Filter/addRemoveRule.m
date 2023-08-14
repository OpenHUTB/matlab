function res=addRemoveRule(this,rule,add)




    p=inputParser;
    p.addParameter('Rule','');
    parse(p,'Rule',rule);
    validateattributes(p.Results.Rule,{'slcoverage.FilterRule'},{'scalar'});

    res=true;
    switch class(rule.Selector.Type)
    case 'slcoverage.BlockSelectorType'
        allPropMap=SlCov.FilterEditor.getPropertyDB;
        id=sprintf('P%d',int32(rule.Selector.Type));
        currProp=allPropMap(id);
        assert(~isempty(currProp));
        if rule.Selector.Type==slcoverage.BlockSelectorType.TemporalEvent
            v.type='Event';
            v.name=rule.Selector.Id;
            currProp.value=v;
            currProp.valueDesc=v.name;
        else
            currProp.value=rule.Selector.Id;
            currProp.valueDesc=rule.Selector.Description;
        end
        if strcmpi(add,'add')
            currProp.mode=int32(rule.Mode);
            this.filter.setFilterByProp(currProp,rule.Rationale);
        else
            this.filter.removeFilterByProp(currProp);
        end

    case 'slcoverage.MetricSelectorType'

        if rule.Selector.Type==slcoverage.MetricSelectorType.DecisionOutcome
            metricName='decision';
        elseif rule.Selector.Type==slcoverage.MetricSelectorType.ConditionOutcome
            metricName='condition';
        elseif rule.Selector.Type==slcoverage.MetricSelectorType.MCDCOutcome
            metricName='mcdc';
        elseif rule.Selector.Type==slcoverage.MetricSelectorType.RelationalBoundaryOutcome
            metricName='cvmetric_Structural_relationalop';
        elseif rule.Selector.Type==slcoverage.MetricSelectorType.SaturationOverflowOutcome
            metricName='cvmetric_Structural_saturate';
        end

        selector=rule.Selector;
        if strcmpi(add,'add')
            this.filter.addMetricFilter(selector.SId,metricName,selector.ObjectiveIndex,selector.OutcomeIndex,int32(rule.Mode),rule.Rationale,selector.Description);
        else
            v.ssid=selector.SId;
            v.type='metric';
            v.name=metricName;
            v.idx=selector.ObjectiveIndex;
            v.outcomeIdx=selector.OutcomeIndex;
            prop.value=v;
            this.filter.removeFilterByProp(prop);
        end

    case 'slcoverage.SFcnSelectorType'
        selector=rule.Selector;
        key=SlCov.FilterEditor.encodeCodeFilterInfo(selector.FileName,...
        selector.FunctionName,...
        selector.Expr,...
        [selector.ExprIndex,selector.OutcomeIndex,selector.DecOrCondIndex],...
        selector.CVMetricType,...
        selector.SId);
        if isequal(selector.Type,slcoverage.SFcnSelectorType.SFcnName)
            allPropMap=SlCov.FilterEditor.getPropertyDB;
            id=sprintf('P%d',int32(rule.Selector.Type));
            currProp=allPropMap(id);
            assert(~isempty(currProp));
            currProp.value=rule.Selector.Id;
            currProp.valueDesc=rule.Selector.Description;
        else
            [codeCovInfo,sid]=SlCov.FilterEditor.decodeCodeFilterInfo(key);
            if~isempty(sid)
                codeKey.ssid=sid;
                codeKey.codeCovInfo=codeCovInfo;
            elseif~isempty(codeCovInfo{1})
                codeKey=codeCovInfo;
            end
            currProp=SlCov.FilterEditor.deriveProperties(codeKey);
        end
        if strcmpi(add,'add')
            currProp.mode=int32(rule.Mode);
            this.filter.setFilterByProp(currProp,rule.Rationale);
        else
            this.filter.removeFilterByProp(currProp);
        end

    case 'slcoverage.CodeSelectorType'
        key=SlCov.FilterEditor.encodeCodeFilterInfo(...
        rule.Selector.FileName,...
        rule.Selector.FunctionName,...
        rule.Selector.Expr,...
        [rule.Selector.ExprIndex,rule.Selector.OutcomeIndex,rule.Selector.DecOrCondIndex],...
        rule.Selector.CVMetricType);
        codeCovInfo=SlCov.FilterEditor.decodeCodeFilterInfo(key);
        currProp=SlCov.FilterEditor.deriveProperties(codeCovInfo);
        if strcmpi(add,'add')
            currProp.mode=int32(rule.Mode);
            this.filter.setFilterByProp(currProp,rule.Rationale);
        else
            this.filter.removeFilterByProp(currProp);
        end
    end
