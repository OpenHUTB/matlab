function y=mod(a,n)







    switch class(a)
    case 'double'
        y=mod(a,n);
    case{'uint8','int8','uint16','int16','uint32','int32'}
        y=mod(double(a),double(n));
    case{'uint64','int64'}
        tmpa=fi(a,0,64,0);
        tmpn=fi(n,0,64,0);
        y=fimod(tmpa,tmpn);
    case 'embedded.fi'
        y=fimod(a,n);
    end


    function y=fimod(a,n)
        if n==0
            y=a;
        elseif a==n
            y=fi(0,numerictype(n));
        else
            a=fi(a,'numerictype',numerictype(a),'RoundMode','floor');
            n=fi(n,'numerictype',numerictype(a),'RoundMode','floor');
            temp=a./n;
            if temp==0
                y=a;
            else
                temp2=n.*temp;
                y=a-temp2;
            end
        end


