function out=getSetNumESBTasks(varargin)




    persistent numTasks;
    if isempty(numTasks)
        numTasks=0;
    end
    if(nargin>0)
        numTasks=varargin{1};
    end
    out=numTasks;
end
