function pm_assert(condition,format,varargin)









    if nargin>0&&~condition

        message='';
        if nargin>1
            message=sprintf(format,varargin{:});
        end





        throwAsCaller(pm_errorstruct('physmod:common:foundation:mli:assert:InternalError',message));

    end

end
