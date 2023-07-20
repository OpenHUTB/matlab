function restart(h,timeout)
























    narginchk(1,2);


    timeoutParamOrder=2;
    if(nargin<timeoutParamOrder)
        timeout=[];
    end
    dtimeout=linkfoundation.util.checkTimeoutParam(nargin,timeoutParamOrder,timeout,[]);


    for k=1:length(h)
        RestartProcessor(h(k),dtimeout);
    end


    function RestartProcessor(h,dtimeout)
        if isempty(dtimeout)
            dtimeout=double(h.timeout);
        end
        h.mIdeModule.ClearAllRequests;
        h.mIdeModule.Restart(dtimeout*1000);


