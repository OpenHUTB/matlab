function qout=aeroblkquatinterp(p,q,h,method)




%#codegen
    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');


    normp=norm(p);
    normq=norm(q);
    sqrteps=sqrt(eps);
    nflagp=(normp>1.0+sqrteps||normp<1.0-sqrteps);
    nflagq=(normq>1.0+sqrteps||normq<1.0-sqrteps);
    if nflagp
        p=aeroblkquatnormalize(p);
    end
    if nflagq
        q=aeroblkquatnormalize(q);
    end

    dotpq=dot(p,q);
    if dotpq<0
        q=-q;
    end


    h=aeroblkcheckRange(h,0,1);


    switch method
    case 0
        qout=locquatmultiply(p,locquatpower(aeroblkquatnormalize(locquatmultiply(locquatconj(p),q)),h));
    case 1
        qout=p*(1-h)+q*h;
    case 2
        qout=p*(1-h)+q*h;
        qout=aeroblkquatnormalize(qout);
    otherwise
        qout=p*(1-h)+q*h;
        qout=aeroblkquatnormalize(qout);
    end
end


function qlog=locquatlog(q)
    qlog=zeros(4,1);
    normv=norm(q(2:4));
    th=atan2(normv,q(1));
    v=q(2:4)/normv;
    if normv~=0.0
        qlog(2:4)=th*v;
    end
end

function qexp=locquatexp(q)
    qexp=zeros(4,1);
    th=norm(q(2:4));
    if th==0
        v=[0,0,0]';
    else
        v=exp(q(1))*sin(th)*q(2:4)/th;
    end
    qexp(1)=exp(q(1))*cos(th);
    qexp(2:4)=v;
end

function qpow=locquatpower(q,t)
    qpow=locquatexp(t*locquatlog(q));
end

function qconj=locquatconj(q)
    qconj=zeros(4,1);
    qconj(1)=q(1);
    qconj(2:4)=-q(2:4);
end

function qmult=locquatmultiply(q,r)
    qmult=zeros(4,1);
    vec=[q(1)*r(2),q(1)*r(3),q(1)*r(4)]+...
    [r(1)*q(2),r(1)*q(3),r(1)*q(4)]+...
    [q(3)*r(4)-q(4)*r(3),q(4)*r(2)-q(2)*r(4),q(2)*r(3)-q(3)*r(2)];
    scalar=q(1)*r(1)-q(2)*r(2)-q(3)*r(3)-q(4)*r(4);

    qmult(1)=scalar;
    qmult(2:4)=vec';
end
