function loadWorkerState(varargin)
    [session,args]=connector.internal.getSessionAccessor(varargin{:});
    loadSession(session,args.includePath);
end
