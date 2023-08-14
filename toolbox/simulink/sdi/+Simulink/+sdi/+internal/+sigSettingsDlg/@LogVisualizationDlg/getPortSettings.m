function ret=getPortSettings(this)



    try
        ps=get(this.Context{1}.portH);
    catch me %#ok<NASGU>
        ps=struct();
    end

    ret.UseCustomName=false;
    ret.CustomName='';
    if isfield(ps,'DataLoggingNameMode')
        ret.UseCustomName=strcmpi(ps.DataLoggingNameMode,'Custom');
        ret.CustomName=ps.DataLoggingName;
    end

    ret.DecimateData=false;
    ret.Decimation=1;
    if isfield(ps,'DataLoggingDecimateData')
        ret.DecimateData=strcmpi(ps.DataLoggingDecimateData,'on');
        ret.Decimation=ps.DataLoggingDecimation;
    end

    ret.LimitDataPoints=false;
    ret.MaxPoints=0;
    if isfield(ps,'DataLoggingLimitDataPoints')
        ret.LimitDataPoints=strcmpi(ps.DataLoggingLimitDataPoints,'on');
        ret.MaxPoints=ps.DataLoggingMaxPoints;
    end

    ret.SampleTime='-1';
    if isfield(ps,'DataLoggingSampleTime')
        ret.SampleTime=ps.DataLoggingSampleTime;
    end
end
