function tclHdlSim(tclCmd,varargin)

















    if nargin>0
        tclCmd=convertStringsToChars(tclCmd);
    end

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if(~exist('tclCmd')||~ischar(tclCmd))
        error(message('HDLLink:TclHdlSim:InvalidTCLCommand'));
    end
    hostName='';
    portNumber='';
    isLocal=1;
    isShared=0;

    switch nargin
    case 1
        isShared=1;
    case 2
        portNumber=varargin{1};
        if(~ischar(portNumber))
            error(message('HDLLink:TclHdlSim:InvalidPortNumber'));
        end
    case 3
        isLocal=0;
        portNumber=varargin{1};
        if(~ischar(portNumber))
            error(message('HDLLink:TclHdlSim:InvalidPortNumber'));
        end
        hostName=varargin{2};
        if(~ischar(hostName))
            error(message('HDLLink:TclHdlSim:InvalidHostName'));
        end
    otherwise
        error(message('HDLLink:TclHdlSim:InvalidArgumentNumber'));
    end

    if~isempty(strmatch('bdroot',inmem))&&...
        ~isempty(bdroot)&&...
        ~strcmp(get_param(bdroot,'simulationStatus'),'stopped')
        error(message('HDLLink:TclHdlSim:RunningSimulink'));
    end
    try
        autopopulate('%^execTcl^%',isLocal,isShared,hostName,portNumber,tclCmd);
    catch ME


        newExc=MException('HDLLink:BreakHdlSim:Error',strrep(ME.message,'autopopulate','tclHdlSim'));
        throw(newExc);
    end
end

