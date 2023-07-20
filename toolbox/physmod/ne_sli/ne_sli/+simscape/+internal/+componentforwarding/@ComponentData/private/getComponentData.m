function[variableData,parameterData]=getComponentData(componentPath,version)



    persistent DataMap
    if isempty(DataMap)
        DataMap=containers.Map;
    end

    theKey=[componentPath,int2str(version)];
    if DataMap.isKey(theKey)
        data=DataMap(theKey);
    else
        data=lGetData(componentPath);
        DataMap(theKey)=data;
    end

    variableData=data{1};
    parameterData=data{2};

end

function data=lGetData(componentPath)

    cs=simscape.schema.loadComponentSchema(componentPath);
    i=cs.info();

    vars=i.Members.Variables;
    nVars=numel(vars);
    variableData=repmat(...
    struct('id','',...
    'value','',...
    'unit','',...
    'priority','',...
    'specify',''),nVars,1);
    for idx=1:nVars


        var=vars(idx);
        variableData(idx)=...
        struct('id',var.ID,...
        'value',lValUnitToMask(var.Default.Value),...
        'unit',var.Default.Value.Unit,...
        'priority',var.Default.Priority,...
        'specify','off');
    end
    params=i.Members.Parameters;
    nParams=numel(params);
    parameterData=repmat(...
    struct('id','',...
    'value','',...
    'unit','',...
    'rtconfig',''),nParams,1);
    for idx=1:nParams

        param=params(idx);
        defaultRTConfig='compiletime';
        parameterData(idx)=...
        struct('id',param.ID,...
        'value',lValUnitToMask(param.Default),...
        'unit',param.Default.Unit,...
        'rtconfig',defaultRTConfig);
    end

    data={variableData,parameterData};
end

function str=lValUnitToMask(in)
    import simscape.engine.sli.internal.cleanmaskvalue;
    if isa(in.Value,'simscape.Value')
        str=cleanmaskvalue(value(in.Value,lGetUnit(in.Unit)));
    else
        assert(ischar(in.Value));
        str=in.Value;
    end
end

function[unit,choices]=lGetUnit(in)
    if ischar(in)
        unit=in;
        if nargout>1
            choices=pm_suggestunits(unit);
        end
    else
        assert(isstruct(in));
        unit=in.Default;
        choices=in.Units;
    end
end
