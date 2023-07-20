function breakHdlSim(varargin)

















    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    hostName='';
    portNumber='';
    isLocal=1;
    isShared=0;

    switch nargin
    case 0
        isShared=1;
    case 1
        portNumber=varargin{1};
        if(~ischar(portNumber))
            error(message('HDLLink:BreakHdlSim:InvalidPortNumber'));
        end
    case 2
        isLocal=0;
        portNumber=varargin{1};
        if(~ischar(portNumber))
            error(message('HDLLink:BreakHdlSim:InvalidPortNumber'));
        end
        hostName=varargin{2};
        if(~ischar(hostName))
            error(message('HDLLink:BreakHdlSim:InvalidHostName'));
        end
    otherwise
        error(message('HDLLink:BreakHdlSim:InvalidArgumentNumber'));
    end

    if~isempty(strmatch('bdroot',inmem))&&...
        ~isempty(bdroot)&&...
        ~strcmp(get_param(bdroot,'simulationStatus'),'stopped')
        error(message('HDLLink:BreakHdlSim:RunningSimulink'));
    end
    try
        autopopulate('%^breakHdlSim^%',isLocal,isShared,hostName,portNumber);
    catch ME


        newExc=MException('HDLLink:BreakHdlSim:Error',strrep(ME.message,'autopopulate','breakHdlSim'));
        throw(newExc);
    end
end

