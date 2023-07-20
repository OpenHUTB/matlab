
function decoded=urldecode(encoded)

    decoded='';

    i=1;
    di=1;
    while i<=numel(encoded)
        utf8Chars=zeros(1,0,'uint8');

        while i+2<=numel(encoded)&&encoded(i)=='%'
            code=encoded(i+1:i+2);
            ch=hex2dec(code);
            i=i+3;
            utf8Chars(end+1)=ch;%#ok<AGROW>
        end

        if~isempty(utf8Chars)
            nextChar=native2unicode(utf8Chars,'UTF-8');
        elseif encoded(i)=='+'
            nextChar=' ';
            i=i+1;
        else
            nextChar=encoded(i);
            i=i+1;
        end

        nextDi=di+numel(nextChar);
        decoded(di:nextDi-1)=nextChar;
        di=nextDi;
    end



    decoded=decoded(1:di-1);

