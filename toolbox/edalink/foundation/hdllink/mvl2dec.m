function x=mvl2dec(l,signed)




















    if nargin>0
        l=convertStringsToChars(l);
    end

    if~ischar(l),error(message('HDLLink:mvl2dec:InvalidType'));end
    if isempty(l),x=[];return,end
    [m,n]=size(l);
    if m>1&&n>1,error(message('HDLLink:mvl2dec:InvalidDimensions'));end
    n=length(l);
    if n>52,error(message('HDLLink:mvl2dec:StringTooLong'));end
    if nargin==1
        signed=false;
    end
    l=l(:)';
    v=l-'0';
    if any(v>1)||any(v<0),
        x=NaN;
    else
        x=sum(v.*pow2(n-1:-1:0));
        if(signed==true&&v(1))
            x=x-pow2(n);
        end
    end
