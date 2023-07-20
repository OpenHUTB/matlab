function result=hdlparseportdims(portdims,nports)














    if nargin==1||isempty(nports)
        result=[];
        return;
    end

    if length(portdims)==1
        result=portdims;
        return;
    end

    if portdims(1)==1||portdims(1)==-2
        result=zeros(3,nports);
    else

        result=zeros(portdims(1)+1,nports);
    end

    k=1;
    port=1;
    while k<=length(portdims)
        if portdims(k)==-2
            portscalar=portdims(k+1);
            result(1,port)=1;
            result(2,port)=0;
            result(3,port)=0;
            k=k+2;
            for sk=1:portscalar
                if portdims(k)==1
                    result(2,port)=result(2,port)+portdims(k+1);
                    k=k+2;
                elseif portdims(k)==2
                    result(2,port)=result(2,port)+...
                    max(portdims(k+1),portdims(k+2));
                    k=k+3;
                else
                    result(2,port)=result(2,port)+max(portdims(k+1:k+portdims(k)));
                    k=k+portdims(k)+1;
                end
            end
            port=port+1;
        else
            for ii=1:portdims(k)+1
                result(ii,port)=portdims(ii);
            end
            k=k+ii;
            port=port+1;
        end
    end
    if port-1~=nports
        error(message('hdlcommon:hdlcommon:portnumberingerror',nports,port-1));
    end





