function errorStruct=pm_errorstruct(msgid,varargin)









    narginchk(1,nargin);
    errorStruct=pm_exception(msgid,varargin{:});

end
