function varargout=floatingPointFullDomainRule(varargin)






















    narginchk(3,4);

    ty1=varargin{1};
    op=varargin{end-1};
    errorMechanism=varargin{end};

    try
        if(nargin==3)
            [varargout{1:nargout}]=feval('_gpu_floatingPointFullDomainRule',op,ty1);
        else
            ty2=varargin{2};
            [varargout{1:nargout}]=feval('_gpu_floatingPointFullDomainRule',op,ty1,ty2);
        end
    catch err
        encounteredError(errorMechanism,err);
    end
