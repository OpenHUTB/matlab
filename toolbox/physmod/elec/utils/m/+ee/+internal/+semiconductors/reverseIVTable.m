function[VVec,IMat]=reverseIVTable(TVec,IVec,VMat)























    VReshape=reshape(VMat,[1,(length(IVec)*length(TVec))]);
    VVec=unique(VReshape);

    IMat=zeros(length(TVec),length(VVec));
    for ii=1:length(TVec)
        IMat(ii,:)=interp1(VMat(ii,:),IVec,VVec,"linear","extrap");
    end

end