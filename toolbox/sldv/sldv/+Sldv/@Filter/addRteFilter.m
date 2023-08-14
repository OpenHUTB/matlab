function addRteFilter(this,ssid,rteObjType,objectiveIdx,dummyIdx,mode,rationale,descr)




    if nargin<8
        descr='';
    end
    prop=addRtePropValue(this,ssid,rteObjType,objectiveIdx,dummyIdx,mode,rationale,descr);
    if~isempty(prop)
        this.setFilterByProp(prop,rationale);
    end
end

function prop=addRtePropValue(this,ssid,rteObjType,objectiveIdx,dummyIdx,mode,rationale,descr)
    prop=[];
    v.ssid=ssid;
    v.type='rte';
    v.name=rteObjType;
    tprop.value=v;
    res=this.filterState.isKey(this.getPropKey(tprop));
    if res
        tprop=this.filterState(this.getPropKey(tprop));
        propValue=tprop.value;
    else
        propValue=[];
    end

    allPropMap=SlCov.FilterEditor.getPropertyDB;
    switch rteObjType
    case 'array_bounds'
        tProp=allPropMap('P26');
    case 'division_by_zero'
        tProp=allPropMap('P27');
    case 'overflow'
        tProp=allPropMap('P28');
    case 'inf_value'
        tProp=allPropMap('P29');
    case 'nan_value'
        tProp=allPropMap('P30');
    case 'subnormal_value'
        tProp=allPropMap('P31');
    case 'design_range'
        tProp=allPropMap('P32');
    case 'read-before-write'
        tProp=allPropMap('P33');
    case 'write-after-read'
        tProp=allPropMap('P34');
    case 'write-after-write'
        tProp=allPropMap('P35');
    case 'block_input_range_violation'
        tProp=allPropMap('P36');
    case 'hisl_0003'
        tProp=allPropMap('P37');
    case 'hisl_0028'
        tProp=allPropMap('P38');
    case 'hisl_0002'
        tProp=allPropMap('P40');
    case 'hisl_0004'
        tProp=allPropMap('P41');
    otherwise
        assert(false);
    end

    tValue.ssid=ssid;
    tValue.type='rte';
    tValue.name=rteObjType;
    tValue.value=[];
    tValue.idx=objectiveIdx;
    tValue.outcomeIdx=dummyIdx;
    tValue.mode=mode;
    tValue.valueDesc=getValueDesc(tValue,descr);
    tValue.rationale=rationale;
    tValue.selectorType=tProp.selectorType;

    if isempty(propValue)
        propValue=tValue;
    else
        for idx=1:numel(propValue)
            if isequalProp(propValue(idx),tValue)
                return;
            end
        end
        propValue(end+1)=tValue;
    end
    if~isempty(propValue)
        prop=tProp;
        assert(~isempty(prop));
        prop.value=propValue;
        prop.valueDesc='rte';
        prop.Rationale='';
        prop.mode=1;
    end
end

function res=isequalProp(value1,value2)
    res=true;

    value1.mode=1;
    value2.mode=1;
    value1.rationale='';
    value2.rationale='';

    if isequal(value1,value2)
        return;
    end
    res=false;
end





function valueDesc=getValueDesc(propValue,descr)
    rte=propValue.name;

    if~isempty(descr)

        valueDesc=descr;
    else

        switch rte
        case 'array_bounds'
            mN='AB';
        case 'division_by_zero'
            mN='DBZ';
        case 'overflow'
            mN='OVF';
        case 'inf_value'
            mN='INF';
        case 'nan_value'
            mN='NAN';
        case 'subnormal_value'
            mN='SUB';
        case 'design_range'
            mN='DR';
        case 'read-before-write'
            mN='RbW';
        case 'write-after-read'
            mN='WaR';
        case 'write-after-write'
            mN='WaW';
        case 'block_input_range_violation'
            mN='BIRV';
        case 'hisl_0002'
            mN='Hisl_0002';
        case 'hisl_0003'
            mN='Hisl_0003';
        case 'hisl_0004'
            mN='Hisl_0004';
        case 'hisl_0028'
            mN='Hisl_0028';
        otherwise
            mN=rte;
        end

        valueDesc=[mN,num2str(propValue.idx)];

        if~isempty(propValue.outcomeIdx)
            outcomeStr=num2str(propValue.outcomeIdx);
            valueDesc=[valueDesc,' ',outcomeStr];
            try
                modelObject=SlCov.FilterEditor.getObject(propValue.ssid);
                if isempty(modelObject)
                    bName=propValue.ssid;
                else
                    bName=modelObject.Name;
                end
                valueDesc=getString(message('Sldv:Filter:InTxt',valueDesc,['"',bName,'"']));
            catch MEx %#ok<NASGU>
            end
        end
    end
end