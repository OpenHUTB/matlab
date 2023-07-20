function x=finv(p,v1,v2)















    if nargin<3
        error(message('stats:finv:TooFewInputs'));
    end

    [errorcode,p,v1,v2]=distchck(3,p,v1,v2);

    if errorcode>0
        error(message('stats:finv:InputSizeMismatch'));
    end


    okV=(0<v1&v1<Inf)&(0<v2&v2<Inf);
    k=(okV&(0<=p&p<=1));
    allOK=all(k(:));


    if~allOK
        if isa(p,'single')||isa(v1,'single')||isa(v2,'single')
            x=NaN(size(k),'single');
        else
            x=NaN(size(k));
        end


        if any(k(:))
            if numel(p)>1,p=p(k);end
            if numel(v1)>1,v1=v1(k);end
            if numel(v2)>1,v2=v2(k);end
        else
            return;
        end
    end


    up=(p>betainc(.5,v1/2,v2/2,'lower'));
    t=zeros(size(p),class(p));
    zUp=betaincinv(p(up),v2(up)/2,v1(up)/2,'upper');
    t(up)=(1-zUp)./zUp;
    lo=~up;
    zLo=betaincinv(p(lo),v1(lo)/2,v2(lo)/2,'lower');
    t(lo)=zLo./(1-zLo);
    xk=t.*v2./v1;


    if allOK
        x=xk;
    else
        x(k)=xk;
    end
