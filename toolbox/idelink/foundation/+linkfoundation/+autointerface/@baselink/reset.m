function reset(h,timeout)

















    narginchk(1,2);


    timeoutParamOrder=2;
    if(nargin<timeoutParamOrder)
        timeout=[];
    end
    dtimeout=linkfoundation.util.checkTimeoutParam(nargin,timeoutParamOrder,timeout,[]);



    for k=1:length(h)
        ResetProcessor(h(k),dtimeout);
    end


    function ResetProcessor(h,dtimeout)
        if isempty(dtimeout)
            dtimeout=double(h.timeout);
        end
        h.mIdeModule.ClearAllRequests;
        h.mIdeModule.Reset(dtimeout*1000);


