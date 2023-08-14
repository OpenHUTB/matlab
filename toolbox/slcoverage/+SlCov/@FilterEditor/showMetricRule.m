function rowIdx=showMetricRule(this,ssid,idx,outcomeIdx,metricName,forCode,varargin)



    if nargin<6
        forCode=false;
    end
    prop.isCode=forCode;
    if prop.isCode
        if isstruct(ssid)
            ssid=[ssid.codeCovInfo(:);{ssid.ssid}];
        end
        v=SlCov.FilterEditor.encodeCodeFilterInfo(ssid{:});
        prop.value=v;
    elseif isstruct(ssid)
        prop=ssid;
    else
        v.ssid=ssid;
        v.type='metric';
        v.name=metricName;
        v.idx=idx;
        v.outcomeIdx=outcomeIdx;
        prop.value=v;
    end


    rowIdx=this.showRule(prop,varargin{:});
