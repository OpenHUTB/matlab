function qout=interp(p,q,f,varargin)%#codegen






    nargoutchk(0,1)


    narginchk(3,4)


    validateattributes(p,{'single','double'},{'ncols',4,'real','finite','nonnan'});
    validateattributes(q,{'single','double'},{'ncols',4,'nrows',size(p,1),'real','finite','nonnan'});
    validateattributes(f,{'single','double'},{'real','finite','nonnan','>=',0,'<=',1,'numel',size(p,1)});
    if length(varargin)==1
        method=lower(varargin{1});
        method=validatestring(method,{'slerp','nlerp','lerp'});
    else
        method='slerp';
    end

    modp=Aero.internal.shared.quaternion.mod(p);
    modqq=Aero.internal.shared.quaternion.mod(q);
    nflagp=logical((modp>1.0+sqrt(eps))+(modp<1.0-sqrt(eps)));
    nflagq=logical((modqq>1.0+sqrt(eps))+(modqq<1.0-sqrt(eps)));
    warnflag=true;
    if any(nflagp)
        p(nflagp,:)=Aero.internal.shared.quaternion.normalize(p(nflagp,:));
        warning(message('aerospace:quatlog:notUnitQuaternion'));
        warnflag=false;
    end
    if any(nflagq)
        q(nflagq,:)=Aero.internal.shared.quaternion.normalize(q(nflagq,:));
        if warnflag
            warning(message('aerospace:quatlog:notUnitQuaternion'));
        end
    end



    dotpq=dot(p',q')<0;
    if any(dotpq)
        q(dotpq,:)=-q(dotpq,:);
    end

    qout=zeros(size(p));
    switch method
    case 'slerp'
        qout=Aero.internal.shared.quaternion.multiply(...
        p,Aero.internal.shared.quaternion.power(...
        Aero.internal.shared.quaternion.normalize(...
        Aero.internal.shared.quaternion.multiply(...
        Aero.internal.shared.quaternion.conj(p),q)),f));
    case 'lerp'
        for k=1:size(p,1)
            qout(k,:)=p(k,:)*(1-f(k))+q(k,:)*f(k);
        end
    case 'nlerp'
        for k=1:size(p,1)
            qout(k,:)=p(k,:)*(1-f(k))+q(k,:)*f(k);
        end
        qout=Aero.internal.shared.quaternion.normalize(qout);
    end

end
