function w=bessely(nu,z,scale)











%#codegen

    coder.allowpcode('plain');
    narginchk(2,3);
    coder.internal.prefer_const(nu);
    coder.internal.assert(isfloat(nu)&&isfloat(z),...
    'MATLAB:bessely:nonFloatInput');
    coder.internal.assert(isreal(nu),...
    'MATLAB:bessely:nonRealNU');
    coder.internal.assert(~issparse(nu)&&~issparse(z),...
    'MATLAB:bessely:sparseInput');


    if nargin==3
        coder.internal.prefer_const(scale);
        coder.internal.assert(isfloat(scale),...
        'MATLAB:bessely:nonFloatInput');
        coder.internal.assert(isscalar(scale)&&isreal(scale)&&...
        (scale==0||scale==1),...
        'MATLAB:bessely:ScaleNotZeroOrOne');
        w=coder.internal.applyBinaryScalarFunction(mfilename,...
        complex(coder.internal.scalarEg(nu,z)),...
        @scalar_bessely,nu,z,scale);
    else
        w=coder.internal.applyBinaryScalarFunction(mfilename,...
        complex(coder.internal.scalarEg(nu,z)),...
        @scalar_bessely,nu,z);
    end



    function w=scalar_bessely(nu,z,scale)
        coder.internal.prefer_const(nu);
        dnu=double(nu);



        zd=complex(double(z));
        if nargin<3
            kode=int32(1);
        else
            coder.internal.prefer_const(scale);
            kode=int32(scale+1);
        end
        fixnu=fix(dnu);
        ierr=int32(0);
        if isnan(dnu)||isnan(zd)
            w=complex(coder.internal.nan);
            return
        elseif zd==0
            w=complex(-coder.internal.inf);
        elseif dnu>=0
            [w,~,ierr]=cbesy(zd,dnu,kode);
        elseif fixnu==dnu
            [w,~,ierr]=cbesy(zd,-dnu,kode);
            if rem(fixnu,2)~=0
                w=-w;
            end
        elseif abs(nu-fixnu)==0.5
            [w,~,ierr]=cbesj(zd,-dnu,kode);
            if rem(fixnu,2)~=0
                w=-w;
            end
        else
            [w,~,ierr]=cbesj(zd,-dnu,kode);
            w=ierrCheckAndModify(ierr,w);
            [w2,~,ierr]=cbesy(zd,-dnu,kode);
            [cosX,sinX]=coder.internal.scalar.cospiAndSinpi(-dnu);
            w=cosX*w2+sinX*w;
        end
        w=ierrCheckAndModify(ierr,w);
        if(isreal(zd)||imag(zd)==0)&&(real(zd)>0)
            w(1)=real(w(1));
        end


