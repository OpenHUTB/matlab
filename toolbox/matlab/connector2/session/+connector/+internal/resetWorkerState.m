function resetWorkerState(varargin)
    session=connector.internal.getSessionAccessor(varargin{:});
    resetSession(session);
end
