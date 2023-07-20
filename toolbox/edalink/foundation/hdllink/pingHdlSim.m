function pid=pingHdlSim(timeOut,varargin)
















    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if(~exist('timeOut','var')||~isnumeric(timeOut))
        error(message('HDLLink:pingHdlSim:InvalidTimeout'));
    end

    timeOutLeft=round(timeOut);
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
            error(message('HDLLink:pingHdlSim:InvalidPortNumber'));
        end
    case 3
        isLocal=0;
        portNumber=varargin{1};
        if(~ischar(portNumber))
            error(message('HDLLink:pingHdlSim:InvalidPortNumber'));
        end
        hostName=varargin{2};
        if(~ischar(hostName))
            error(message('HDLLink:pingHdlSim:InvalidHostName'));
        end
    otherwise
        error(message('HDLLink:pingHdlSim:InvalidArgumentNumber'));
    end

    if~isempty(strmatch('bdroot',inmem))&&...
        ~isempty(bdroot)&&...
        ~strcmp(get_param(bdroot,'simulationStatus'),'stopped')
        error(message('HDLLink:pingHdlSim:RunningSimulink'));
    end


    tstart=tic;

    while(1)
        try
            pid=autopopulate('%^getPid^%',isLocal,isShared,hostName,portNumber);
            return;
        catch err
            pid=-1;
            timeOutLeft=timeOutLeft-1;
            if(timeOutLeft<0)
                break;
            end


            telapsed=toc(tstart);
            if(telapsed>=(timeOut+1))
                break;
            end
            pause(1);
        end
    end

    if(nargout==0)
        error(message('HDLLink:pingHdlSim:timeout'));
    end

end
