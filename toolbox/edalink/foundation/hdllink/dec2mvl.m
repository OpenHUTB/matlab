function s=dec2mvl(d,n)





















    narginchk(1,2);

    if isempty(d)
        s='';
        return
    end

    d=d(:);
    d=round(double(d));


    if(d>(2^52-1))
        error(message('HDLLink:dec2mvl:ValueIsMoreThanUpperBoundaryLimit'));
    elseif(d<(-2^51+1))
        error(message('HDLLink:dec2mvl:ValueIsLessThanLowerBoundaryLimit'));
    end

    if(nargin<2)
        n=1;
    else
        if(ischar(n)),error(message('HDLLink:dec2mvl:CharValue'));end
        n=double(n);
        if~isscalar(n)||n<0||ischar(n),error(message('HDLLink:dec2mvl:InvalidBitArg'));end
        n=round(n);
    end;





    [~,e]=log2(max(d));
    [x,y]=log2(min(d));


    if(y>=e&&min(d)<=0)

        if x==-0.5
            e=y;
        else
            e=y+1;
        end
    end

    for i=1:length(d)



        a{i}=char(abs(rem(floor(d(i)*pow2(1-max(n,e):0)),2))+'0');%#ok<AGROW> % added abs for negative numbers
        s=char(a);
    end
