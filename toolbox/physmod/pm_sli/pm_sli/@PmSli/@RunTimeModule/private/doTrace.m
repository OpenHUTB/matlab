function isTracingOn=doTrace(varargin)







    persistent fTrace

    if nargin==1
        fTrace=varargin{1};
    end
    isTracingOn=fTrace;



