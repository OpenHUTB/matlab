classdef(Sealed,Abstract,Hidden)quaternion









    methods(Hidden,Static,Access={?Aero.internal.math.quat,...
        ?matlabshared.satellitescenario.internal.Simulator})
        qout=conj(q);
        qout=divide(q,r);
        qout=exp(q);
        qout=interp(p,q,f,varargin);
        qout=inv(q);
        qout=log(q);
        qout=mod(q);
        qout=multiply(q,varargin);
        qout=norm(q);
        qout=normalize(q);
        qout=power(q,pow);
        qout=rotate(q,r);
        dcm=toDCM(q,r);
    end
end