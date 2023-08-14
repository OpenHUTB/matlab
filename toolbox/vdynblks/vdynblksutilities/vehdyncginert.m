function[Rbar,mbar,Ibar]=vehdyncginert(R,M,Imat)%#codegen
    coder.allowpcode('plain')


    Rbar=sum(repmat(M,[1,3]).*R./sum(M),1);
    mbar=sum(M);
    Ibar=pllaxis(R-repmat(Rbar,[8,1]),M,Imat);
end
function Ibar=pllaxis(R,M,Imat)%#codegen

    Itemp=zeros(3,3,length(M));
    for idx=1:length(M)
        Itemp(:,:,idx)=Imat(:,:,idx)+M(idx).*(dot(R(idx,:)',R(idx,:)')*eye(3,3)-R(idx,:)'*R(idx,:)).*[1,-1,-1;-1,1,-1;-1,-1,1];
    end
    Ibar=sum(Itemp,3);
end