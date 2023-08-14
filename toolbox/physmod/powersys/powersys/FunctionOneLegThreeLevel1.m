function[V]=FunctionOneLegThreeLevel1(g,Vdc)
%#codegen
    coder.allowpcode('plain');
    dataType='double';
    V=zeros(2,1,dataType);
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
    V(1)=-k1*Vdc(2)+(1-g(3))*Vdc(1);
    V(2)=-k2*Vdc(1)+(1-g(2))*Vdc(2);





