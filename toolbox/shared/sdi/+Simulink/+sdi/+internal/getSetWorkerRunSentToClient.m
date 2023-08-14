function ret=getSetWorkerRunSentToClient(varargin)



    persistent WAS_SENT
    if isempty(WAS_SENT)
        WAS_SENT=false;
    end


    ret=WAS_SENT;


    if~isempty(varargin)
        WAS_SENT=varargin{1};
    end
end
