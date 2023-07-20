function errorIfArray(h)




    if length(h)~=1
        error(message('ERRORHANDLER:autointerface:ObjectArrayNotAllowed'));
    end

