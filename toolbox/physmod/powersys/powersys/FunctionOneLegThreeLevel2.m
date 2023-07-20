function[Idc]=FunctionOneLegThreeLevel2(g,I)
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
        Idc(1)=k2*In+I(1);
        Idc(2)=g(2)*In-I(2);
    else
        Idc(1)=-g(3)*In-I(1);
        Idc(2)=-k1*In-I(2);
    end



