function g=gcdAnyInt(a,b)








































    validateattributes(a,{'numeric','embedded.fi','logical'},{'real','finite','scalar','integer'},mfilename);
    validateattributes(b,{'numeric','embedded.fi','logical'},{'real','finite','scalar','integer'},mfilename);

    a=prepInput(a);
    b=prepInput(b);

    if a==b||b==0
        g=a;
        return
    elseif a==0
        g=b;
        return
    end




    feDrop=min(a.FixedExponent,b.FixedExponent);
    a=divByPow2(a,feDrop);
    b=divByPow2(b,feDrop);
    d=feDrop;

    assert(~isEven(a)||~isEven(b));

    fiOne=fixed.internal.math.fiOne();
    while a~=b
        if a==fiOne||b==fiOne
            a=fiOne;
            break
        elseif isEven(a)
            a=removeAllTrailingZeros(a);
        elseif isEven(b)
            b=removeAllTrailingZeros(b);
        elseif a>b



            a=divByPow2(a-b,1);
        else
            b=divByPow2(b-a,1);
        end
    end

    g=mulByPow2(a,d);
    g=fixed.internal.type.tightFi(g);
end

function y=prepInput(x)

    y=fixed.internal.type.tightFi(x);
    y=fixed.internal.math.fullSlopeBiasToBinPt(y);
    y=safeAbs(y);
    y=fixed.internal.type.tightFi(y);
end

function b=isEven(u)
    b=u.FixedExponent>0||(0==u.getlsb);
end


function u=removeAllTrailingZeros(u)
    n=u.FixedExponent+...
    fixed.internal.math.countMinTrailingZeros(u);
    u=divByPow2(u,n);
end


function u=divByPow2(u,n)
    feDrop=min(n,u.FixedExponent);
    if feDrop>0
        nt2=numerictype(u);
        nt2.FixedExponent=nt2.FixedExponent-feDrop;
        u=reinterpretcast(u,nt2);
        n=n-feDrop;
    end
    if n>0
        u=bitsra(u,n);
    end
end

function u=mulByPow2(u,n)
    assert(n>=0);
    nt2=numerictype(u);
    nt2.FixedExponent=nt2.FixedExponent+n;
    u=reinterpretcast(u,nt2);
end

function y=safeAbs(x)


    if x>=0
        y=x;
    else
        y=fixed.internal.math.fiMinusOne()*x;
    end

end
