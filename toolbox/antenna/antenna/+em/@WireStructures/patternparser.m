function[parseobj,azimuth,elevation]=patternparser(obj,frequency,...
    inputdata,nolhs)






    if isempty(inputdata)||~any(strcmpi(inputdata,'Type'))
        numcell=numel(inputdata);
        inputdata{numcell+1}='Type';
        if(isRadiatorLossy(obj))
            inputdata{numcell+2}='Gain';
        else
            inputdata{numcell+2}='Directivity';
        end
    elseif any(strcmpi(inputdata,'Type'))
        if any(strcmpi(inputdata,'Directivity'))&&isRadiatorLossy(obj)
            error(message('antenna:antennaerrors:NoDirectivityInLossyMaterial'));
        end
    end

    defaultaz=1;
    defaultel=1;
    if~isempty(inputdata)
        if numel(inputdata)>=2&&isnumeric(inputdata{1})&&...
            isnumeric(inputdata{2})
            numcell=numel(inputdata);
            updatedipdata=cell(1,numcell+2);
            updatedipdata{1}='azimuth';
            updatedipdata{2}=(inputdata{1});
            updatedipdata{3}='elevation';
            updatedipdata{4}=(inputdata{2});
            updatedipdata(5:end)=inputdata(3:end);
            defaultaz=0;
            defaultel=0;
        elseif numel(inputdata)>=2&&isnumeric(inputdata{1})&&...
            ~isnumeric(inputdata{2})
            numcell=numel(inputdata);
            updatedipdata=cell(1,numcell+1);
            updatedipdata{1}='azimuth';
            updatedipdata{2}=(inputdata{1});
            updatedipdata(3:end)=inputdata(2:end);
            defaultaz=0;
        elseif numel(inputdata)==1&&isnumeric(inputdata{1})
            numcell=numel(inputdata);
            updatedipdata=cell(1,numcell+1);
            updatedipdata{1}='azimuth';
            updatedipdata{2}=(inputdata{1});
            updatedipdata(3:end)=inputdata(2:end);
            defaultaz=0;
        else
            updatedipdata=inputdata;
        end
    else
        updatedipdata=inputdata;
    end


    parseobj=inputParser;
    parseobj.FunctionName='pattern';
    expectedcoord={'polar','rectangular','uv'};
    expectedtype={'directivity','efield','power','powerdb','gain','realizedgain','phase'};
    expectedpol={'combined','H','V','RHCP','LHCP'};
    expectedplotstyle={'overlay','waterfall'};
    expectedpatternOptions=PatternPlotOptions;

    if nolhs
        typeValidationFcn=@(x)validateattributes(x,{'double'},...
        {'scalar','nonempty','real','finite',...
        'nonnan','positive'},'pattern');
    else
        typeValidationFcn=@(x)validateattributes(x,{'double'},...
        {'vector','nonempty','real','finite',...
        'nonnan','positive'},'pattern');
    end
    addRequired(parseobj,'frequency',typeValidationFcn);

    typeValidationAng=@(x)validateattributes(x,{'double'},...
    {'vector','nonempty','real','finite','nonnan'},'pattern');
    addParameter(parseobj,'azimuth',-180:5:180,typeValidationAng);
    addParameter(parseobj,'elevation',-90:5:90,typeValidationAng);

    addParameter(parseobj,'CoordinateSystem','polar',...
    @(x)any(validatestring(x,expectedcoord)));
    addParameter(parseobj,'Type','directivity',...
    @(x)any(validatestring(x,expectedtype)));
    addParameter(parseobj,'Polarization','combined',...
    @(x)any(validatestring(x,expectedpol)));
    addParameter(parseobj,'Normalize',0,@islogical);
    addParameter(parseobj,'PlotStyle','overlay',...
    @(x)any(validatestring(x,expectedplotstyle)));
    addParameter(parseobj,'PatternOptions',expectedpatternOptions,...
    @(x)validateoptions(x));




    if isa(obj,'em.Array')
        typeValidationFcnarray=@(x)validateattributes(x,...
        {'double'},{'finite','real','positive','nonnan',...
        'scalar','<=',getTotalArrayElems(obj)},...
        'pattern');
        addParameter(parseobj,'ElementNumber',[],typeValidationFcnarray);
    else
        addParameter(parseobj,'ElementNumber',[]);
        addParameter(parseobj,'Termination',[]);
    end

    parse(parseobj,frequency,updatedipdata{:});
    azimuth=parseobj.Results.azimuth;
    elevation=parseobj.Results.elevation;
    frequency=parseobj.Results.frequency;


    if strcmpi(parseobj.Results.CoordinateSystem,'uv')
        if~isscalar(frequency)
            error(message('antenna:antennaerrors:InvalidPatternSlicesUV'));
        end
        if defaultaz
            azimuth=-1:0.01:1;
        else
            validateattributes(azimuth,{'double'},{'>=',-1,'<=',1},...
            'pattern','u',3);
        end
        if defaultel
            elevation=-1:0.01:1;
        else
            validateattributes(elevation,{'double'},{'>=',-1,'<=',...
            1},'pattern','v',4);
        end
    end


    if~isempty(parseobj.Results.ElementNumber)
        error(message('antenna:antennaerrors:InvalidPatternWireOption','ElementNumber'));
    end
    if~isempty(parseobj.Results.Termination)
        error(message('antenna:antennaerrors:InvalidPatternWireOption','Termination'));
    end
    if~isscalar(frequency)&&~isscalar(azimuth)&&~isscalar(elevation)
        error(message('antenna:antennaerrors:InvalidPatternOption'));
    end

    if strcmpi(parseobj.Results.PlotStyle,'waterfall')&&...
        ~strcmpi(parseobj.Results.CoordinateSystem,'rectangular')
        error(message('antenna:antennaerrors:InvalidPatternCoord'));
    end





end




function op=validateoptions(options)
    if(strcmpi(class(options),'PatternPlotOptions'))&&isscalar(options)
        op=true;
    else
        op=false;
        error(message('antenna:antennaerrors:InvalidPatternPlotOptions'));
    end
end
