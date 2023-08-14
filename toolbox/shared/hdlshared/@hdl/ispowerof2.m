function result=ispowerof2(varargin)






















    switch class(varargin{1})
    case 'double'
        result=isp2_double(varargin{:});
    case{'uint8','int8','uint16','int16','uint32','int32','uint64','int64'}
        tmp={double(varargin{1}),varargin{2:end}};
        result=isp2_double(tmp{:});
    case 'embedded.fi'
        result=isp2_fi(varargin{:});
    end

    function result=isp2_double(n,~,bp)
        if abs(n)<eps
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


        function result=isp2_fi(n,~,~)

            b=fix(bin(n)-'0');
            if n<0
                if b(1)==1&&all(b(2:end)==0)
                    result=true;
                    return;
                else
                    b=fix(bin(abs(n))-'0');
                end
            end
            result=sum(b)==1;




