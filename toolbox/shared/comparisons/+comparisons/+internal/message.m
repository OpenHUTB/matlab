function str=message(type,key,varargin)








    msg=message(key,varargin{:});
    str=msg.getString();
    switch type
    case 'error'


        E=MException(key,'%s',str);
        throwAsCaller(E);
    case 'warning'
        warning(key,'%s',str);
    case 'message'
    otherwise

        error('comparisons:comparisons:Internal','Unknown action: %s',type);
    end
end
