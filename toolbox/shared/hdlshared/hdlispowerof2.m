function result=hdlispowerof2(n,nbits,bp)





















    if((any(real(n)~=0,'all')&&any(imag(n)~=0,'all'))||any(abs(n)<eps,'all'))
        result=false;
    else
        templog=log2(abs(n));
        if templog-floor(templog)<eps
            if nargin==1
                result=true;
            elseif nargin==3
                if templog>=0
                    result=true;
                else
                    if bp>=-templog
                        result=true;
                    else
                        result=false;
                    end
                end
            else
                error(message('HDLShared:directemit:toofewargs'));
            end
        else
            result=false;
        end
    end





