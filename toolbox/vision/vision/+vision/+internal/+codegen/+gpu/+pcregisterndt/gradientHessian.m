function[grad,hess]=gradientHessian(qryPtMeanSubtracted,iCov,d1,d2,Jp,Hp)
%#codegen

    coder.allowpcode('plain');
    qC=gpucoder.transpose(qryPtMeanSubtracted)*iCov;
    qCq=zeros(1,'like',qryPtMeanSubtracted);

    coder.unroll;
    for i=1:3
        qCq=qCq+qC(i).*qryPtMeanSubtracted(i);
    end

    qCJ=qC*Jp;
    c=d1*d2*exp((-d2/2)*qCq);
    grad=c.*qCJ;

    JpT=gpucoder.transpose(Jp);
    JJ=JpT*iCov*Jp;
    qCJ_sq=gpucoder.transpose(qCJ)*qCJ;
    h=qC(1)*Hp(:,:,1)+qC(2)*Hp(:,:,2)+qC(3)*Hp(:,:,3);

    hess=c*(-d2*qCJ_sq+h+JJ);
end
