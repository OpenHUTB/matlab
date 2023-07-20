function sig=createSignal(this,varargin)


    sig=Simulink.sdi.Signal.empty();
    try

        opts=locParseOptions(varargin{:});


        sigID=Simulink.sdi.internal.safeTransaction(@locCreateSignal,this,opts);
        if sigID
            sig=Simulink.sdi.Signal(this.Repo,sigID);
        end




        locUpdateUI(this,sig);

    catch me
        throwAsCaller(me);
    end
end


function ret=locParseOptions(varargin)
    p=inputParser;

    addParameter(p,'Name','',@ischar);
    addParameter(p,'Model','',@ischar);
    addParameter(p,'DataType','double',@ischar);
    addParameter(p,'Units','',@ischar);
    addParameter(p,'SampleTime','',@ischar);
    addParameter(p,'BlockPath','',@ischar);
    addParameter(p,'PortIndex',0,@(x)validateattributes(x,{'numeric'},{'integer','scalar'}));
    addParameter(p,'Dimensions',1,@(x)validateattributes(x,{'numeric'},{'integer','vector','nonnegative'}));
    addParameter(p,'Type','discrete',@(x)locValidateStr(x,{'discrete','continuous','event'}));
    addParameter(p,'Complexity','real',@(x)locValidateStr(x,{'real','complex'}));
    addParameter(p,'Domain','',@ischar);

    parse(p,varargin{:});
    ret=p.Results;
end


function ret=locValidateStr(varargin)
    str=validatestring(varargin{:});
    ret=~isempty(str);
end


function sigID=locCreateSignal(this,opts)



    opts.Dimensions=int32(opts.Dimensions);
    numDims=numel(opts.Dimensions);
    if numDims>1
        timeDim=int32(numDims+1);
    else
        timeDim=int32(1);
    end
    channelIdx=int32(1);


    bComplex=strcmpi(opts.Complexity,'complex');


    opts.PortIndex=int32(opts.PortIndex);


    dataVals.Time=0;
    dataVals.Data=locGetSampleGroundValue(opts.DataType,bComplex);


    switch lower(opts.Type)
    case{'discrete','event'}
        interpMethod='zoh';

    case 'continuous'
        interpMethod='linear';
    end


    sigID=this.Repo.add(...
    [],...
    this.id,...
    '',...
    '',...
    '',...
    dataVals,...
    opts.BlockPath,...
    opts.Model,...
    opts.Name,...
    timeDim,...
    opts.Dimensions,...
    opts.PortIndex,...
    channelIdx,...
    '',...
    [],...
    int32(0),...
    '',...
    interpMethod,...
    opts.Units);


    if~isempty(opts.SampleTime)
        setSignalSampleTimeLabel(this.Repo,sigID,opts.SampleTime);
    end
    if~isempty(opts.Domain)
        this.Repo.setSignalDomainType(sigID,opts.Domain);
    end
    if strcmpi(opts.Type,'event')
        this.Repo.setSignalIsEventBased(sigID,true);
    end
end


function ret=locGetSampleGroundValue(dataType,bComplex)


    enumInfo=enumeration(dataType);
    if~isempty(enumInfo)

        ret=enumInfo(1);
    elseif contains(dataType,'fixdt')

        dto=eval(dataType);
        ret=fi(0,dto);
    elseif strcmpi(dataType,'string')

        ret="";
    else

        ret=zeros(dataType);
    end


    if bComplex
        ret=ret+1i*(1+ret);
    end
end


function locUpdateUI(this,sig)

    if~isempty(sig)
        fw=Simulink.sdi.internal.AppFramework.getSetFramework();
        fw.onSignalAdded(this.id);
    end
end
