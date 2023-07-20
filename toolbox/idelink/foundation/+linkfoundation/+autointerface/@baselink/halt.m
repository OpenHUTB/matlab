function halt(h,timeout)




    narginchk(1,2);
    focusstate=linkfoundation.util.getCmdWndFocus;


    timeoutParamOrder=2;
    if(nargin<timeoutParamOrder)
        timeout=[];
    end
    dtimeout=linkfoundation.util.checkTimeoutParam(nargin,timeoutParamOrder,timeout,[]);


    for k=1:length(h)
        HaltProcessor(h(k),dtimeout);
    end

    linkfoundation.util.grabCmdWndFocus(focusstate);


    function HaltProcessor(h,dtimeout)
        if isempty(dtimeout)
            dtimeout=double(h.timeout);
        end

        if isrunning(h)
            h.mIdeModule.ClearAllRequests;
            h.mIdeModule.Halt(dtimeout*1000);
        end


