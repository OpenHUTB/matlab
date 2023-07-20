



function error(errId,varargin)
    msg=message(errId,varargin{:});



    throwAsCaller(MException(errId,'%s',msg.getString()));
end
