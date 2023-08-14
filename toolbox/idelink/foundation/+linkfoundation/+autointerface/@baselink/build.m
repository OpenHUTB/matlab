function[res,warn]=build(h,optime,timeout)


























    narginchk(1,3);
    linkfoundation.util.errorIfArray(h);


    focusstate=linkfoundation.util.getCmdWndFocus;

    if(nargin==1)||((nargin==2)&&isnumeric(optime)),
        buildAll=false;
        if nargin==1,
            timeout=[];
        else
            timeout=optime;
        end
    elseif(nargin==2)||(nargin==3),
        if ischar(optime)&&strcmpi('all',optime)
            buildAll=true;
            if nargin==2,
                timeout=[];
            end
        else
            error(message('ERRORHANDLER:autointerface:InvalidBuildOption'));
        end
    end


    timeoutParamOrder=2;
    if(nargin<timeoutParamOrder)
        timeout=[];
    end
    dtimeout=linkfoundation.util.checkTimeoutParam(nargin,timeoutParamOrder,timeout,h.buildtimeout);


    dtimeout=dtimeout*1000;



    h.mIdeModule.ClearAllRequests;
    pres=h.mIdeModule.Build(buildAll,dtimeout);


    res=pres(1);
    warn=pres(3);


    linkfoundation.util.grabCmdWndFocus(focusstate);


