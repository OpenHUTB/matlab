function checkNegTimeout(timeout)




    if(timeout<0)
        DAStudio.error('ERRORHANDLER:utils:InvalidNegativeTimeoutValue',timeout);
    end

