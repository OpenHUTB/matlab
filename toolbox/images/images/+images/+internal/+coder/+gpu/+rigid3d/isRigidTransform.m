






function isRigid=isRigidTransform(T,thresh)
%#codegen

    coder.gpu.kernelfun;
    coder.allowpcode('plain');
    coder.inline('never');

    if nargin<2
        thresh=100;
    end

    rot=T(1:3,1:3);

    [~,singularValues,~,~]=coder.internal.lapack.xgesvd_gpu(rot,'S','S');
    singValueMax=gpucoder.internal.max(singularValues);
    singValueMin=gpucoder.internal.min(singularValues);
    isRigid=singValueMax-singValueMin<1000*eps(max(singularValues(:)));

    rotMatDet=rot(1,1)*(rot(2,2)*rot(3,3)-rot(2,3)*rot(3,2))-...
    rot(1,2)*(rot(2,1)*rot(3,3)-rot(2,3)*rot(3,1))+...
    rot(1,3)*(rot(2,1)*rot(3,2)-rot(3,1)*rot(2,2));
    isRigid=isRigid&&abs(rotMatDet-1)<thresh*eps(class(rot));

end