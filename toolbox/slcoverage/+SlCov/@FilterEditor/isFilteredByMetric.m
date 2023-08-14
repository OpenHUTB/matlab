function[res,propInstance]=isFilteredByMetric(this,ssid,metricName)





    propInstance=[];

    [forCode,~,codeKey]=SlCov.FilterEditor.isForCode(ssid);
    if forCode
        v.ssid=codeKey;
        v.type='';
        v.name='';
    else
        v.ssid=ssid;
        v.type='metric';
        v.name=metricName;
    end

    prop.value=v;
    res=this.isFilteredByProp(prop);
    if res
        propInstance=this.filterState(this.getPropKey(prop));
    end


