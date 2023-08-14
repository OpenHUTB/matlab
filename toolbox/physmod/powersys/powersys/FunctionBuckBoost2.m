function[Idc]=FunctionBuckBoost2(g,I)
%#codegen
    coder.allowpcode('plain');
    Idc=g*I;
