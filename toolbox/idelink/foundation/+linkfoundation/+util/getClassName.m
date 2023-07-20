function className=getClassName(h,formatOpt)




    className=class(h);
    idx=strfind(className,'.');
    if~isempty(idx)
        className=className(idx(end)+1:end);
    end

    if nargin>1
        switch lower(formatOpt)
        case 'upper'
            className=upper(className);
        case 'lower'
            className=lower(className);
        otherwise
            error(message('ERRORHANDLER:utils:UnrecognizedOption',formatOpt));
        end
    end


