function[V]=FunctionHalfBridge1(g,Vdc)
%#codegen
    coder.allowpcode('plain');
    dataType='double';
    V=zeros(2,1,dataType);
    V(1)=(-1.0*g(2)+1.0)*Vdc;
    V(2)=-g(1)*Vdc;
