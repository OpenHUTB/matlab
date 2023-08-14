function[V,Idc]=FunctionBuckBoost(g,Vdc,I)
%#codegen
    coder.allowpcode('plain');
    V=-1.0*g*Vdc;
    Idc=g*I;