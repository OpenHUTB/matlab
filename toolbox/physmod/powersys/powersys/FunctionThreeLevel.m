function[V]=FunctionThreeLevel(g,Vdc)
%#codegen
    coder.allowpcode('plain');
    dataType='double';
    V=zeros(6,1,dataType);

    V(1)=-min([g(3),g(4)])*Vdc(2)+(1-g(3))*Vdc(1);
    V(2)=-min([g(1),g(2)])*Vdc(1)+(1-g(2))*Vdc(2);

    V(3)=-min([g(7),g(8)])*Vdc(2)+(1-g(7))*Vdc(1);
    V(4)=-min([g(5),g(6)])*Vdc(1)+(1-g(6))*Vdc(2);

    V(5)=-min([g(11),g(12)])*Vdc(2)+(1-g(11))*Vdc(1);
    V(6)=-min([g(9),g(10)])*Vdc(1)+(1-g(10))*Vdc(2);



