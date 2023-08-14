function propMap=deriveMetricProperties(ssid)




    propMap=[];
    metricNames=SlCov.FilterEditor.getSupportedMetricNames;
    for idx=1:numel(metricNames)
        defs=SlCov.CoverageAPI.getCoverageDef(ssid,metricNames{idx});
        propMap=addMetricToPropMap(propMap,ssid,defs);
    end
end

function propMap=addMetricToPropMap(propMap,ssid,defs)
    pdb=SlCov.FilterEditor.getPropertyDB;
    for idx=1:numel(defs)
        cDef=defs(idx);
        metricName=cDef.name;
        for objectiveIdx=1:numel(cDef.cvIds)
            cvId=cDef.cvIds(objectiveIdx);
            if strcmpi(metricName,'decision')
                numOfProps=numel(cDef.details(objectiveIdx).outcome);
                propTempl=pdb('P18');
            elseif strcmpi(metricName,'condition')
                numOfProps=2;
                propTempl=pdb('P19');
            elseif strcmpi(metricName,'mcdc')
                numOfProps=numel(cDef.details(objectiveIdx).condition);
                propTempl=pdb('P39');
            elseif strcmpi(metricName,'cvmetric_Structural_relationalop')
                numOfProps=numel(cDef.details(objectiveIdx).outcome);
                propTempl=pdb('P24');
            elseif strcmpi(metricName,'cvmetric_Structural_saturate')
                numOfProps=numel(cDef.details(objectiveIdx).outcome);
                propTempl=pdb('P25');
            end

            for outcomeIdx=1:numOfProps
                propValue=getMetricPropValue(ssid,cvId,metricName,objectiveIdx,0,outcomeIdx,0);
                if~isempty(propValue)
                    prop=propTempl;
                    prop.value=propValue;
                    prop.valueDesc='metric';
                    prop.Rationale='';
                    prop.mode=0;
                    if isempty(propMap)
                        propMap=prop;
                    else
                        propMap(end+1)=prop;
                    end
                end
            end
        end
    end
end


function propValue=getMetricPropValue(ssid,cvId,metricName,objectiveIdx,objectiveModes,outcomeIdx,outcomeModes)
    propValue=[];
    tValue.ssid=ssid;
    tValue.type='metric';
    tValue.name=metricName;
    tValue.idx=objectiveIdx;
    tValue.objectiveModes=objectiveModes;
    tValue.outcomeIdx=outcomeIdx;
    tValue.outcomeModes=outcomeModes;
    tValue.valueDesc=SlCov.FilterEditor.getMetricFilterValueDescr(metricName,cvId,outcomeIdx,false);
    tValue.valueDesc=cvi.ReportUtils.html_to_str(tValue.valueDesc);
    if isempty(propValue)
        propValue=tValue;
    else
        propValue(end+1)=tValue;
    end
end
