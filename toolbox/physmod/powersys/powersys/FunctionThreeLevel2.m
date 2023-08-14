function[Idc]=FunctionThreeLevel2(g,I)
%#codegen
    coder.allowpcode('plain');
    dataType='double';
    Idc=zeros(2,1,dataType);

    if(g(1)>g(2))
        k2=g(2);
    else
        k2=g(1);
    end
    if(g(4)>g(3))
        k1=g(3);
    else
        k1=g(4);
    end
    In=I(2)-I(1);
    if(In>=0)
        Idc1=k2*In+I(1);
        Idc2=g(2)*In-I(2);
    else
        Idc1=-g(3)*In-I(1);
        Idc2=-k1*In-I(2);
    end


    if(g(5)>g(6))
        k2=g(6);
    else
        k2=g(5);
    end
    if(g(8)>g(7))
        k1=g(7);
    else
        k1=g(8);
    end
    In=I(4)-I(3);
    if(In>=0)
        Idc3=k2*In+I(3);
        Idc4=g(6)*In-I(4);
    else
        Idc3=-g(7)*In-I(3);
        Idc4=-k1*In-I(4);
    end

    if(g(9)>g(10))
        k2=g(10);
    else
        k2=g(9);
    end
    if(g(12)>g(11))
        k1=g(11);
    else
        k1=g(12);
    end
    In=I(6)-I(5);
    if(In>=0)
        Idc5=k2*In+I(5);
        Idc6=g(10)*In-I(6);
    else
        Idc5=-g(11)*In-I(5);
        Idc6=-k1*In-I(6);
    end

    Idc(1)=Idc1+Idc3+Idc5;
    Idc(2)=Idc2+Idc4+Idc6;



