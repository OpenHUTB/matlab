function[a,b,c,e,rkE]=minreal_inf(a,b,c,e,EBCScale)























    if isempty(e)
        rkE=size(a,1);return
    end


    if nargin<5
        EBCScale=[norm(e,1),norm(b,1),norm(c,inf)];
    end
    EBCScale(EBCScale==0)=1;


    tol=ltipack.getTolerance('rank');



    [a,b,c,e]=reduceEBCs(a,b,c,e);


    [a,b,c,e]=reduceEBC(a,b,c,e,3*tol,EBCScale);


    ns=size(a,1);
    if ns>0
        [u,s,v]=svd(e);
        svE=diag(s);


        rkE=sum(svE>EBCScale(1)*(tol/3));
        if rkE<ns

            e=diag([svE(1:rkE);zeros(ns-rkE,1)]);
            a=u'*a*v;b=u'*b;c=c*v;


            a22=a(rkE+1:ns,rkE+1:ns);
            a22(abs(a22)<100*eps*norm(a,1))=0;
            a(rkE+1:ns,rkE+1:ns)=a22;
        elseif norm(eye(ns)-e,1)<tol

            e=[];
        end
    else
        rkE=0;
    end
