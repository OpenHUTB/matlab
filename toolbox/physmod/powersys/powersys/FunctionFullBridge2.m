function[Idc]=FunctionFullBridge2(g,I)
%#codegen
    coder.allowpcode('plain');
    Idc=((g(2)+g(3)-1)*I(1))+((g(1)+g(4)-1)*I(2));
