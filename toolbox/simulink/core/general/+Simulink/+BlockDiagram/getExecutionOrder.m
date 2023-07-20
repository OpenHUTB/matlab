function getExecutionOrder(varargin)



















    taskIdx=-1;
    if nargin==1
        model=varargin{1};
    elseif nargin==2
        model=varargin{1};
        taskIdx=varargin{2};
    else
        disp('Invalid number of arguments.');
        return;
    end

    slprivate('openExecOrderDisplay',model,taskIdx);
