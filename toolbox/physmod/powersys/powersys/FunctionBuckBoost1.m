function[V]=FunctionBuckBoost1(g,Vdc)
%#codegen
    coder.allowpcode('plain');
    V=-1.0*g*Vdc;
