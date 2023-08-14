










function simStopped=autoblkschecksimstopped(varargin)
    block=varargin{1};
    if nargin<2
        initFlag=false;
    else
        initFlag=varargin{2};
    end
    simMode=get_param(bdroot(block),'SimulationStatus');
    if strcmp(simMode,'running')||strcmp(simMode,'paused')||strcmp(simMode,'compiled')||...
        strcmp(simMode,'restarting')||(strcmp(simMode,'initializing')&&initFlag)
        simStopped=false;
    else
        simStopped=true;
    end
end
