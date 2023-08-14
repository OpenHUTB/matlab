function arg=createTflArgFromParamVals(~,argType,varargin)



















































































































    len=length(varargin);
    if mod(len,2)~=0
        DAStudio.error('RTW:tfl:oddArguments');
    end

    name='';
    type='RTW_IO_INPUT';
    baseType='';
    dimRange=[1,1;inf,inf];
    isSigned=true;
    wordLength=16;
    checkSlope=true;
    checkBias=true;
    dtm='Fixed-point: binary point scaling';
    scl='BinaryPoint';
    dt='Fixed';
    saf=1.0;
    fe=-15;
    bias=0.0;
    fl=15;
    value=0.0;
    slope=1.0;


    dtmSet=false;
    dtsSet=false;
    flSet=false;
    safSet=false;
    for idx=1:2:len
        switch(varargin{idx})
        case 'Name'
            name=varargin{idx+1};
        case 'IOType'
            type=varargin{idx+1};
        case 'BaseType'
            baseType=varargin{idx+1};
        case 'DimRange'
            dimRange=varargin{idx+1};
        case 'IsSigned'
            isSigned=varargin{idx+1};
        case 'WordLength'
            wordLength=varargin{idx+1};
        case 'CheckSlope'
            checkSlope=varargin{idx+1};
        case 'CheckBias'
            checkBias=varargin{idx+1};
        case 'DataTypeMode'
            dtm=varargin{idx+1};
            dtmSet=true;
        case 'DataType'
            dt=varargin{idx+1};
            dtsSet=true;
        case 'Scaling'
            scl=varargin{idx+1};
            dtsSet=true;
        case 'SlopeAdjustmentFactor'
            saf=varargin{idx+1};
            safSet=true;
        case 'FixedExponent'
            fe=varargin{idx+1};
            safSet=true;
        case 'Slope'
            slope=varargin{idx+1};
        case 'Bias'
            bias=varargin{idx+1};
        case 'FractionLength'
            fl=varargin{idx+1};
            dtmSet=true;
            flSet=true;
        case 'Value'
            value=varargin{idx+1};
        otherwise
            DAStudio.error('RTW:tfl:unknownParameter',varargin{idx});
        end
    end

    switch argType
    case 'RTW.TflArgNumeric'
        if dtmSet&&dtsSet
            DAStudio.error('RTW:tfl:dtmAndDtsSpecified');
        end

        t=numerictype;
        t.Signed=isSigned;
        t.WordLength=wordLength;
        if dtmSet
            t.DataTypeMode=dtm;
            if strcmp(dtm,'Fixed-point: binary point scaling')
                if flSet
                    t.FractionLength=fl;
                else
                    t.SlopeAdjustmentFactor=saf;
                    t.FixedExponent=fe;
                end
            elseif strcmp(dtm,'Fixed-point: slope and bias scaling')
                if safSet
                    t.SlopeAdjustmentFactor=saf;
                    t.FixedExponent=fe;
                    t.Bias=bias;
                else
                    t.Slope=slope;
                    t.Bias=bias;
                end
            end
        else
            if dtsSet

                t.Scaling=scl;
                t.Slope=slope;
                t.Bias=bias;
                t.DataType=dt;
            end
        end
        arg=RTW.TflArgNumeric(name,type,t);
        arg.CheckBias=checkBias;
        arg.CheckSlope=checkSlope;

    case 'RTW.TflArgNumericConstant'
        if dtmSet&&dtsSet
            DAStudio.error('RTW:tfl:dtmAndDtsSpecified');
        end

        t=numerictype;
        t.Signed=isSigned;
        t.WordLength=wordLength;
        if dtmSet
            t.DataTypeMode=dtm;
            if strcmp(dtm,'Fixed-point: binary point scaling')
                if flSet
                    t.FractionLength=fl;
                else
                    t.SlopeAdjustmentFactor=saf;
                    t.FixedExponent=fe;
                end
            elseif strcmp(dtm,'Fixed-point: slope and bias scaling')
                if safSet
                    t.SlopeAdjustmentFactor=saf;
                    t.FixedExponent=fe;
                    t.Bias=bias;
                else
                    t.Slope=slope;
                    t.Bias=bias;
                end
            end
        else
            if dtsSet
                t.DataType=dt;
                t.Scaling=scl;
                t.Slope=slope;
                t.Bias=bias;
            end
        end
        arg=RTW.TflArgNumericConstant(name,type,value,t);
    case 'RTW.TflArgPointer'
        if isempty(baseType)
            arg=RTW.TflArgPointer(name,type);
        else
            arg=RTW.TflArgPointer(name,type,baseType);
        end
    case 'RTW.TflArgChar'
        arg=RTW.TflArgChar(name,type,isSigned,wordLength);
    case 'RTW.TflArgComplex'
        if isempty(baseType)
            arg=RTW.TflArgComplex(name,type);
        else
            arg=RTW.TflArgComplex(name,type,baseType);
        end
    case 'RTW.TflArgVoid'
        arg=RTW.TflArgVoid(name,type);
    case 'RTW.TflArgMatrix'
        arg=RTW.TflArgMatrix(name,type,baseType);
        arg.DimRange=dimRange;
        arg.CheckBias=checkBias&&arg.CheckBias;
        arg.CheckSlope=checkSlope&&arg.CheckSlope;
    end






