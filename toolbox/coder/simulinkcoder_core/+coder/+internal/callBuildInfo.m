function[tf,varargout]=callBuildInfo(model,throwError,method,varargin)



    tf=false;
    try
        modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(model);
        if isempty(modelCodegenMgr)
            return;
        end

        buildInfo=modelCodegenMgr.BuildInfo;
        if isempty(buildInfo)
            return;
        end

        [varargout{1:nargout-1}]=feval(method,buildInfo,varargin{:});
        tf=true;
    catch exc
        if throwError
            rethrow(exc);
        end
        if(nargout>1)
            varargout(1)={exc};
        end
        if(nargout>2)
            varargout(2:nargout-1)={[]};
        end
    end