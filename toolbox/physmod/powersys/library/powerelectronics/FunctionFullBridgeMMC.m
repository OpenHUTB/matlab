function[V,Idc]=FunctionFullBridgeMMC(g,Vdc,I,n,ModelType)
%#codegen
    m=n;
    coder.allowpcode('plain');
    dataType='double';
    g1=zeros(m,1,dataType);
    g2=zeros(m,1,dataType);
    g3=zeros(m,1,dataType);
    g4=zeros(m,1,dataType);
    Vm=zeros(m,1,dataType);
    Vp=zeros(m,1,dataType);
    Idc=zeros(m,1,dataType);
    V=zeros(2,1,dataType);

    if ModelType==3
        for p=1:m
            g1(p)=g(1+(p-1));
            g2(p)=g(m+p);
            g3(p)=g(2*m+p);
            g4(p)=g(3*m+p);
        end
    else
        for p=1:m
            g1(p)=g(1+4*(p-1));
            g2(p)=g(2+4*(p-1));
            g3(p)=g(3+4*(p-1));
            g4(p)=g(4+4*(p-1));
        end
    end
    for p=1:m
        Vp(p)=-1.0*(g2(p)+g3(p)-1)*Vdc(p);
        Vm(p)=-1.0*(g1(p)+g4(p)-1)*Vdc(p);
        Idc(p)=((g2(p)+g3(p)-1)*I(1))+((g1(p)+g4(p)-1)*I(2));
    end
    V(1)=sum(Vp);
    V(2)=sum(Vm);


