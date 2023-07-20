function write(h,address,data,timeout)








































































    narginchk(3,4);
    linkfoundation.util.errorIfArray(h);


    if isempty(data),
        return;
    end


    timeoutParamOrder=4;
    if(nargin<timeoutParamOrder)
        timeout=[];
    end
    dtimeout=linkfoundation.util.checkTimeoutParam(nargin,timeoutParamOrder,timeout,h.timeout);



    if isnumeric(address)&&(numel(address)==1),
        address=[address,h.page];
    elseif iscell(address)
        if ischar(address{1})
            linkfoundation.util.checkIfValidHex(address{1});
        end
        if length(address)==1,
            address{2}=h.page;
        end
    elseif ischar(address),
        linkfoundation.util.checkIfValidHex(address);
        tmp{1}=address;
        tmp{2}=h.page;
        address=tmp;
    end


    if iscell(address)

        if ischar((address{1}))
            addr(1)=hex2dec(address{1});
        else
            addr(1)=address(1);
        end

        if ischar((address{2}))
            addr(2)=hex2dec(address{2});
        else
            addr(2)=address{2};
        end
    else
        addr=address;
    end


    data=linkfoundation.util.convertDataTo1xN(data);
    count=numel(data);


    try
        h.mIdeModule.ClearAllRequests();
        h.mIdeModule.Write(addr(1),addr(2),data,count,dtimeout*1000);
    catch wrtException

        if ide_ifReadWriteSizeLimitReached(h,wrtException)

            ide_writeLargeData(h,addr,data,dtimeout);
        else
            rethrow(wrtException);
        end
    end


