function dtimeout=checkTimeoutParam(numargs,timeoutOrder,timeout,objTimeout)




    dtimeout=[];
    if(numargs>=timeoutOrder)&&(~isempty(timeout)),

        if~isnumeric(timeout)||(numel(timeout)~=1),
            DAStudio.error('ERRORHANDLER:autointerface:InvalidTimeoutValue');
        end

        dtimeout=double(timeout);

        if(dtimeout<0)
            error(message('ERRORHANDLER:utils:InvalidNegativeTimeoutValue',num2str(timeout)));
        end

    else

        if~isempty(objTimeout)
            dtimeout=double(objTimeout);
        end





    end


