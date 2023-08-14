function connect2target(h,dtimeout)





    narginchk(1,2);
    linkfoundation.util.errorIfArray(h);

    if nargin==1
        dtimeout=h.mIdeConnectionTimeout;
    end

    if~isnumeric(dtimeout)
        DAStudio.error('ERRORHANDLER:autointerface:InvalidTimeoutValue');
    end

    isSimulator=strcmp(h.targetinfo.targettype,'simulator');
    if~isSimulator,
        h.mIdeModule.TargetConnect(dtimeout*1000);
    end

