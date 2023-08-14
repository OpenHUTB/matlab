function throwInternal(errArg,varargin)





    if ischar(errArg)||isstring(errArg)
        errArg=sprintf(errArg,varargin{:});
    else
        narginchk(1,1);
    end
    codergui.internal.util.customError(errArg,'Namespace','CoderInternal','StackOffset',2);
end