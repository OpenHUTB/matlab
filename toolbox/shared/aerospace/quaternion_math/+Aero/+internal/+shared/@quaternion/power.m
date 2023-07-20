function qout=power(q,pow)%#codegen






    validateattributes(q,{'numeric'},{'ncols',4,'real','finite','nonnan'})
    validateattributes(pow,{'numeric'},{'real','finite','nonnan'})


    modq=Aero.internal.shared.quaternion.mod(q);


    nflag=logical((modq>1.0+sqrt(eps))+(modq<1.0-sqrt(eps)));
    if any(nflag)
        q(nflag,:)=Aero.internal.shared.quaternion.normalize(q(nflag,:));
        warning(message('aerospace:quatlog:notUnitQuaternion'));
    end


    qout=Aero.internal.shared.quaternion.exp(pow(:).*Aero.internal.shared.quaternion.log(q));

end