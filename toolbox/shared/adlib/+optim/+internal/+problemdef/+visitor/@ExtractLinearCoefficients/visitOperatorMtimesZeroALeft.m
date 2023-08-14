function[Aout,bout]=visitOperatorMtimesZeroALeft(~,op,bLeft,ARight,bRight)










    M=op.LeftSize(1);
    K=op.LeftSize(2);
    P=op.RightSize(2);
    kronMat=kron(speye(P),reshape(bLeft,[M,K])');
    Aout=ARight*kronMat;
    bout=bRight'*kronMat;
    bout=bout(:);

end

