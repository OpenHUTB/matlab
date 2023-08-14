function y=factor(x)








    switch class(x)
    case 'double'
        y=factor(abs(x));
    case{'uint8','int8','uint16','int16','uint32','int32'}
        y=factor(abs(double(x)));
    case{'uint64','int64'}
        tmpx=fi(x,0,64,0);
        y=fifactor(tmpx);
    case 'embedded.fi'
        y=fifactor(x);
    end

    function y=fifactor(x)

        intx=reinterpretcast(abs(x),numerictype(x.signed,x.wordLength,0));

        p=primes(sqrt(double(intx)));
        y=[];
        while intx>1,
            d=find(hdl.mod(intx,p)==0);
            if isempty(d)
                y=[y,intx];
                break;
            end
            p=p(d);
            y=[y,p];
            intx=intx/prod(p);
        end

        y=sort(y);




