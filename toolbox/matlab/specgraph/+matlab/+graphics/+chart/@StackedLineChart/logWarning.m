function logWarning(hObj,varargin)













    if hObj.Constructed
        hObj.Presenter.logWarning(varargin{:});
    end
