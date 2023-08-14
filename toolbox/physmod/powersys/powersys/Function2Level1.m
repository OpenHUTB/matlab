function[V]=Function2Level1(g,Vdc)
%#codegen
    coder.allowpcode('plain');

    V=zeros(6,1,'double');

    V(1)=(1.0-g(2))*Vdc;
    V(2)=-g(1)*Vdc;
    V(3)=(1.0-g(4))*Vdc;
    V(4)=-g(3)*Vdc;
    V(5)=(1.0-g(6))*Vdc;
    V(6)=-g(5)*Vdc;


