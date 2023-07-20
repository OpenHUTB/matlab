function varargout=hdlManagerEval(managerMethod,varargin)




    if nargout>0
        varargout=cell(1,nargout);
        [varargout{:}]=feval(managerMethod,emlhdlcoder.WorkFlow.Manager.instance,varargin{:});
    else
        feval(managerMethod,emlhdlcoder.WorkFlow.Manager.instance,varargin{:});
    end
end