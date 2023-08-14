function pm_error(msgid,varargin)










    narginchk(1,nargin);





    throwAsCaller(pm_errorstruct(msgid,varargin{:}));

end
