function saveWorkerState(varargin)
    session=connector.internal.getSessionAccessor(varargin{:});
    saveSession(session);
end

