function addMetricFilter(this,ssid,metricName,objectiveIdx,outcomeIdx,mode,rationale,descr)




    prop=addMetricPropValue(this,ssid,metricName,objectiveIdx,outcomeIdx,mode,rationale,descr);
    if~isempty(prop)

        this.setFilterByProp(prop,rationale,true);
    end
end


function prop=addMetricPropValue(this,ssid,metricName,objectiveIdx,outcomeIdx,mode,rationale,descr)
    prop=[];
    v.ssid=ssid;
    v.type='metric';
    v.name=metricName;
    tprop.value=v;
    res=this.filterState.isKey(this.getPropKey(tprop));
    if res
        tprop=this.filterState(this.getPropKey(tprop));
        propValue=tprop.value;
    else
        propValue=[];
    end

    allPropMap=SlCov.FilterEditor.getPropertyDB;
    if strcmpi(metricName,'decision')
        tProp=allPropMap('P18');
        selectorType=slcoverage.MetricSelectorType.DecisionOutcome;
    elseif strcmpi(metricName,'condition')
        tProp=allPropMap('P19');
        selectorType=slcoverage.MetricSelectorType.ConditionOutcome;
    elseif strcmpi(metricName,'mcdc')
        tProp=allPropMap('P39');
        selectorType=slcoverage.MetricSelectorType.MCDCOutcome;
    elseif strcmpi(metricName,'cvmetric_Structural_relationalop')
        tProp=allPropMap('P24');
        selectorType=slcoverage.MetricSelectorType.RelationalBoundaryOutcome;
    elseif strcmpi(metricName,'cvmetric_Structural_saturate')
        tProp=allPropMap('P25');
        selectorType=slcoverage.MetricSelectorType.SaturationOverflowOutcome;
    end

    tValue.ssid=ssid;
    tValue.type='metric';
    tValue.name=metricName;
    tValue.value=[];
    tValue.idx=objectiveIdx;
    tValue.outcomeIdx=outcomeIdx;
    tValue.mode=mode;
    tValue.valueDesc=getValueDesc(tValue,descr);
    tValue.rationale=rationale;
    tValue.selectorType=selectorType;

    if isempty(propValue)
        propValue=tValue;
    else
        found=false;
        if this.overwriteRules
            found=false;
            for idx=1:numel(propValue)
                if isequalProp(propValue(idx),tValue)

                    propValue(idx).mode=tValue.mode;


                    if~isempty(tValue.rationale)
                        propValue(idx).rationale=tValue.rationale;
                    end
                    found=true;
                    break;
                end
            end
        end
        if~found
            propValue(end+1)=tValue;
        end
    end

    if~isempty(propValue)
        prop=tProp;
        assert(~isempty(prop));
        prop.value=propValue;
        prop.valueDesc='metric';
        prop.Rationale='';
        prop.mode=mode;
    end
end


function res=isequalProp(value1,value2)
    res=true;

    value1.mode=1;
    value2.mode=1;
    value1.rationale='';
    value2.rationale='';
    value1.valueDesc='';
    value2.valueDesc='';

    if isequal(value1,value2)

        return;
    end
    res=false;
end


function valueDesc=getValueDesc(propValue,descr)
    isCondition=false;
    metricName=propValue.name;

    if~isempty(descr)

        valueDesc=descr;
    else


        switch metricName
        case 'decision'
            mN='D';
        case 'condition'
            mN='C';
            isCondition=true;
        otherwise
            mN=metricName;
        end

        valueDesc=[mN,num2str(propValue.idx)];

        if~isempty(propValue.outcomeIdx)
            if isCondition
                if propValue.outcomeIdx==2
                    outcomeStr='F';
                else
                    outcomeStr='T';
                end
            else
                outcomeStr=num2str(propValue.outcomeIdx);
            end
            valueDesc=[valueDesc,' ',outcomeStr];
            try
                modelObject=SlCov.FilterEditor.getObject(propValue.ssid);
                if isempty(modelObject)
                    bName=propValue.ssid;
                else
                    bName=modelObject.Name;
                end
                valueDesc=getString(message('Slvnv:simcoverage:filterEditor:InTxt',valueDesc,['"',bName,'"']));
            catch MEx %#ok<NASGU>
            end
        end
    end
end
