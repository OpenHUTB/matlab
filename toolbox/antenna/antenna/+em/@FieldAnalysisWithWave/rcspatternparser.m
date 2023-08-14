function[parseobj,azimuth,elevation,azimuthTx,elevationTx,txrxangflag]=rcspatternparser(obj,frequency,...
    inputdata,nolhs)




















    azimuthTx=[];
    elevationTx=[];
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
        elseif numel(inputdata)>=2&&isnumeric(inputdata{1})&&...
            ~isnumeric(inputdata{2})
            numcell=numel(inputdata);
            updatedipdata=cell(1,numcell+1);
            updatedipdata{1}='azimuth';
            updatedipdata{2}=(inputdata{1});
            updatedipdata(3:end)=inputdata(2:end);
        elseif numel(inputdata)==1&&isnumeric(inputdata{1})
            numcell=numel(inputdata);
            updatedipdata=cell(1,numcell+1);
            updatedipdata{1}='azimuth';
            updatedipdata{2}=(inputdata{1});
            updatedipdata(3:end)=inputdata(2:end);
        else
            updatedipdata=inputdata;
        end
    else
        updatedipdata=inputdata;
    end





    if(any(strcmpi('azimuth',updatedipdata))||...
        any(strcmpi('elevation',updatedipdata)))&&...
        (any(strcmpi('TransmitAngle',updatedipdata))||...
        any(strcmpi('ReceiveAngle',updatedipdata)))
        error(message('antenna:antennaerrors:InvalidRCSAnglePair'));
    end












    functionName='rcs';
    parseobj=inputParser;
    parseobj.FunctionName=functionName;
    parseobj.KeepUnmatched=false;
    expectedcoord={'polar','rectangular'};
    expectedscale={'log','linear'};
    expectedtype={'magnitude','complex'};
    expectedpol={'VV','HH','HV','VH','combined'};
    expectedsolver={'PO','MoM','FMM'};
    expectedpatternOptions=PatternPlotOptions;

    typeValidationFcn=@(x)validateattributes(x,{'double'},...
    {'scalar','nonempty','real','finite',...
    'nonnan','positive'},functionName);

    addRequired(parseobj,'frequency',typeValidationFcn);

    typeValidationAng=@(x)validateattributes(x,{'double'},...
    {'vector','nonempty','real','finite','nonnan'},functionName);
    typeValidationTxAng=@(x)validateattributes(x,{'double'},...
    {'size',[2,1],'nonempty','real','finite','nonnan'},functionName);
    typeValidationRxAng=@(x)validateattributes(x,{'double'},...
    {'size',[2,NaN],'nonempty','real','finite','nonnan'},functionName);
    addParameter(parseobj,'azimuth',0,typeValidationAng);
    addParameter(parseobj,'elevation',0:5:360,typeValidationAng);
    addParameter(parseobj,'TransmitAngle',[0;0],typeValidationTxAng);
    addParameter(parseobj,'ReceiveAngle',[zeros(1,73);0:5:360],typeValidationRxAng);
    addParameter(parseobj,'EnableGPU',false,...
    @(x)validateattributes(x,{'numeric','logical'},...
    {'binary','scalar','nonempty','integer','finite','nonnan'},...
    functionName));
    addParameter(parseobj,'CoordinateSystem','polar',...
    @(x)any(validatestring(x,expectedcoord)));
    addParameter(parseobj,'Scale','dBsm',...
    @(x)any(validatestring(x,expectedscale)));
    addParameter(parseobj,'Type','Magnitude',...
    @(x)any(validatestring(x,expectedtype)));
    addParameter(parseobj,'Solver','PO',...
    @(x)any(validatestring(x,expectedsolver)));
    addParameter(parseobj,'Polarization','VV',...
    @(x)any(validatestring(x,expectedpol)));
    addParameter(parseobj,'patternOptions',expectedpatternOptions,...
    @(x)validateoptions(x));

    addParameter(parseobj,'Normalize',0,@islogical);

    parse(parseobj,frequency,updatedipdata{:});
    if any(strcmpi('TransmitAngle',updatedipdata))||any(strcmpi('ReceiveAngle',updatedipdata))
        txrxangflag=true;
        azimuth=parseobj.Results.ReceiveAngle(1,:);
        elevation=parseobj.Results.ReceiveAngle(2,:);
        azimuthTx=parseobj.Results.TransmitAngle(1,:);
        elevationTx=parseobj.Results.TransmitAngle(2,:);
    else
        txrxangflag=false;
        azimuth=parseobj.Results.azimuth;
        elevation=parseobj.Results.elevation;
    end
    frequency=parseobj.Results.frequency;

    if~isscalar(frequency)&&~isscalar(azimuth)&&~isscalar(elevation)
        error(message('antenna:antennaerrors:InvalidPatternOption'));
    end

    if isvector(azimuth)&&isvector(elevation)
        if(numel(unique(azimuth))~=1)&&(numel(unique(elevation))~=1)
            error(message('antenna:antennaerrors:ReceiveRCSAnglesNotInPlane'));
        end
    end



    if any(strcmpi(parseobj.Results.Solver,{'MoM','FMM'}))&&parseobj.Results.EnableGPU
        error(message('antenna:antennaerrors:Unsupported','Use of GPU with MoM or FMM as solver','rcs'));
    end

    if~nolhs&&strcmpi(parseobj.Results.Type,'Complex')
        error(message('antenna:antennaerrors:Unsupported','Switch the ''Type'' input to magnitude; A complex type RCS plot','rcs'));
    end

end


function op=validateoptions(options)
    if(strcmpi(class(options),'PatternPlotOptions'))
        op=true;
    else
        op=false;
        error('The patternOptions should be a PatternPlotOptions object');
    end
end
