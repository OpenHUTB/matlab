function runto(h,func,opt,timeout)















    narginchk(4,4);
    linkfoundation.util.errorIfArray(h);


    funcAddress=address(h,func);
    if isempty(funcAddress)
        error(message('ERRORHANDLER:autointerface:FunctionNotFound',func));
    end


    insert(h,funcAddress,'break');

    try

        h.mIdeModule.ClearAllRequests;
        h.mIdeModule.RunToHalt(timeout*1000);
    catch runException

        remove(h,funcAddress,'break');

        rethrow(runException);
    end


    if~isequal(h.mIdeModule.GetPC,funcAddress(1))
        warning(message('ERRORHANDLER:autointerface:ExecutionDiverged',func,func,func));
    end


    remove(h,funcAddress,'break');

