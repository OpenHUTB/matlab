function resp=read(h,address,datatype,count,timeout)


























































































    narginchk(3,5);
    linkfoundation.util.errorIfArray(h);


    timeoutParamOrder=5;
    if(nargin<timeoutParamOrder)
        timeout=[];
    end
    dtimeout=linkfoundation.util.checkTimeoutParam(nargin,timeoutParamOrder,timeout,h.timeout);



    address=ide_getCompleteAddress(h,address);


    if ischar(datatype)
        if~any(strcmpi(datatype,linkfoundation.util.getValidMLDataTypes));
            error(message('ERRORHANDLER:autointerface:UnsupportedDataTypeValue',datatype));
        end
    else
        error(message('ERRORHANDLER:autointerface:InvalidNonCharDataType'));
    end


    if nargin==3,
        count=1;
    elseif nargin>3
        if~isnumeric(count)
            error(message('ERRORHANDLER:autointerface:InvalidNonNumericCount'));
        end
    end


    usercount=count;
    [count,reshapeData]=linkfoundation.util.convertSizeTo1xN(count);
    if count<1,
        error(message('ERRORHANDLER:autointerface:InvalidNegativecCount'));
    end


    try
        sampledata=linkfoundation.util.createSampleData(count,datatype);
        h.mIdeModule.ClearAllRequests();
        resp=h.mIdeModule.Read(address(1),address(2),sampledata,count,dtimeout*1000);
    catch rdException

        if ide_ifReadWriteSizeLimitReached(h,rdException)

            resp=ide_readLargeData(h,address,datatype,usercount,dtimeout);
        else
            rethrow(rdException);
        end
    end


    if reshapeData
        resp=reshape(resp,usercount);
    end

