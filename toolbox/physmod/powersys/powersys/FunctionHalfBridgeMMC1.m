function[V]=FunctionHalfBridgeMMC1(g,Vdc,n,ModelType)
%#codegen
    m=n;
    coder.allowpcode('plain');
    dataType='double';
    g1=zeros(m,1,dataType);
    g2=zeros(m,1,dataType);
    Vm=zeros(m,1,dataType);
    Vp=zeros(m,1,dataType);
    V=zeros(2,1,dataType);

    if ModelType==3
        for p=1:m
            g1(p)=g(1+(p-1));
            g2(p)=g(m+p);
        end
    else
        for p=1:m
            g1(p)=g(1+2*(p-1));
            g2(p)=g(2*p);
        end
    end

    for p=1:m
        Vp(p)=(-g2(p)+1.0)*Vdc(p);
        Vm(p)=-g1(p)*Vdc(p);
    end
    V(1)=sum(Vp);
    V(2)=sum(Vm);
