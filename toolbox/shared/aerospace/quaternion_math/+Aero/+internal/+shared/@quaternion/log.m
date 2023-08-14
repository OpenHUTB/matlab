function qout=log(q)%#codegen






    validateattributes(q,{'numeric'},{'ncols',4,'real','finite','nonnan'});


    modq=Aero.internal.shared.quaternion.mod(q);


    nflag=logical((modq>1.0+sqrt(eps))+(modq<1.0-sqrt(eps)));
    if any(nflag)
        q(nflag,:)=Aero.internal.shared.quaternion.normalize(q(nflag,:));
        warning(message('aerospace:quatlog:notUnitQuaternion'));
    end


    len=size(q,1);
    normv=arrayfun(@(k)norm(q(k,2:4)),1:len,'UniformOutput',true)';
    th=atan2(normv,q(:,1));


    qout=zeros(size(q));


    tmp=arrayfun(@(k)th(k)*q(k,2:4)/normv(k),1:len,'UniformOutput',false);
    tmp=reshape(cell2mat(tmp'),length(modq),3);
    qout(normv~=0,2:4)=tmp(normv~=0,:);

end