function pm_abort(format,varargin)










    message='';
    if nargin>0
        message=sprintf(format,varargin{:});
    end





    throwAsCaller(pm_errorstruct('physmod:common:foundation:mli:assert:InternalError',message));

end
