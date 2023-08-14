function resp=regread(h,regname,represent,timeout)







































    narginchk(2,4);
    linkfoundation.util.errorIfArray(h);


    timeoutParamOrder=4;
    if(nargin<timeoutParamOrder),
        timeout=[];
    end
    dtimeout=linkfoundation.util.checkTimeoutParam(nargin,timeoutParamOrder,timeout,h.timeout);


    if~ischar(regname)
        error(message('ERRORHANDLER:autointerface:Register_InvalidNonCharRegName','REGREAD'));
    end


    if nargin==2
        represent='2scomp';
    elseif nargin>=3
        CheckRepresent(h,represent);
    end


    resp=proc_regread(h,regname,represent,dtimeout);


    function CheckRepresent(h,represent)
        methodDesc='REGREAD';
        if~ischar(represent)
            error(message('ERRORHANDLER:autointerface:Register_InvalidNonCharRepresent',methodDesc,'Third'));
        elseif~any(strcmpi(represent,{'binary','2scomp','ieee'}))
            error(message('ERRORHANDLER:autointerface:Register_UnsupportedRepresentValue',methodDesc,represent));
        end

