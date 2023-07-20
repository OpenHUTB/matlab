function sldbg=getInstance(varargin)





    persistent localObj

    if~isempty(varargin)
        if~isempty(localObj)&&isvalid(localObj)
            localObj.delete;
        end
        localObj=stm.internal.StmDebugger(varargin{:});
    end

    sldbg=localObj;
end

