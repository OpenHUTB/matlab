function[V]=FunctionFullBridge1(g,Vdc)
%#codegen
    coder.allowpcode('plain');
    dataType='double';
    V=zeros(2,1,dataType);
    V(1)=-1.0*(g(2)+g(3)-1)*Vdc;
    V(2)=-1.0*(g(1)+g(4)-1)*Vdc;

