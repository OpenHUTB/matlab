function funcSet=uSafeSetParam(h,block,varargin)










    funcSet={'ModelUpdater.safeSetParam',block,varargin{:}};%#ok<*CCAT>

    if(doUpdate(h))
        ModelUpdater.safeSetParam(block,varargin{:});
    end

end
