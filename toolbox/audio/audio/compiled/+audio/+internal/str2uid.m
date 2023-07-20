function uid=str2uid(str)







































    if isnumeric(str)

        hash=str;
    else
        assert(ischar(str)||isstring(str),"expected string input");

        hash=hashString(str);
    end


    hash=mod(hash,6854629);

    fourDigits=num2digits(hash);

    symbols='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    uid=string(symbols(fourDigits+1));
end

function hash=hashString(str)
    hash=polyval(double(char(str)),2);
end

function digits=num2digits(num)
    assert(0<=num&&num<52^4-26^4,'number is outside valid range');

    N=52^4;
    if num<N/2

        placeValues=[52*52*52,52*52,52,1];
        digits=convert(num,placeValues);

    elseif num<3/4*N


        num=num-N/2;
        placeValues=[26*52*52,52*52,52,1];
        digits=convert(num,placeValues);
        digits(1)=digits(1)+26;

    elseif num<7/8*N


        num=num-3/4*N;
        placeValues=[26*26*52,26*52,52,1];
        digits=convert(num,placeValues);
        digits(1:2)=digits(1:2)+26;

    elseif num<15/16*N


        num=num-7/8*N;
        placeValues=[26*26*26,26*26,26,1];
        digits=convert(num,placeValues);
        digits(1:3)=digits(1:3)+26;

    end
    assert(any(digits<26),'produced UniqueId with all lowercase characters');
end




function digits=convert(num,placeValues)
    digits=[0,0,0,0];
    for i=1:3
        digits(i)=floor(num/placeValues(i));
        num=num-digits(i)*placeValues(i);
    end
    digits(4)=num;
end
