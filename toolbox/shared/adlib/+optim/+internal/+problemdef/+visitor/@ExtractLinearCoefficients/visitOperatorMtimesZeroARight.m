function[Aout,bout]=visitOperatorMtimesZeroARight(~,op,ALeft,bLeft,bRight)

















    M=op.LeftSize(1);
    K=op.LeftSize(2);
    P=op.RightSize(2);
    kronMat=kron(reshape(bRight,[K,P]),speye(M));
    Aout=ALeft*kronMat;
    bout=bLeft'*kronMat;
    bout=bout(:);

end