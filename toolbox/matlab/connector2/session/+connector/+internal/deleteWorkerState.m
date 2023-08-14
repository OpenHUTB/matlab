function deleteWorkerState(varargin)
    session=connector.internal.getSessionAccessor(varargin{:});
    deleteSession(session);
end
