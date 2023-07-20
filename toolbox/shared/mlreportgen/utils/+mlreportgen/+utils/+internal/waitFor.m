function success=waitFor(func,varargin)























    p=inputParser();
    p.addParameter("TimeOut",5,@(x)isnumeric(x)&&(x>0));
    p.addParameter("MinDelay",0.01,@(x)isnumeric(x)&&(x>0));
    parse(p,varargin{:});
    args=p.Results;

    timeout=args.TimeOut;
    minDelay=args.MinDelay;
    totalTime=0;
    success=func();
    while(~success&&(totalTime<timeout))
        success=func();
        totalTime=totalTime+minDelay;
        pause(minDelay);
    end
end
