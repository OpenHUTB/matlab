function w=besselj(nu,z,scale)











%#codegen

    coder.allowpcode('plain');
    narginchk(2,3);
    coder.internal.prefer_const(nu);
    coder.internal.assert(isfloat(nu)&&isfloat(z),...
    'MATLAB:besselj:nonFloatInput');
    coder.internal.assert(isreal(nu),...
    'MATLAB:besselj:nonRealNU');
    coder.internal.assert(~issparse(nu)&&~issparse(z),...
    'MATLAB:besselj:sparseInput');


    if nargin==3
        coder.internal.prefer_const(scale);
        coder.internal.assert(isfloat(scale),...
        'MATLAB:besselj:nonFloatInput');
        coder.internal.assert(isscalar(scale)&&isreal(scale)&&...
        (scale==0||scale==1),...
        'MATLAB:besselj:ScaleNotZeroOrOne');
        w=coder.internal.applyBinaryScalarFunction(mfilename,...
        complex(coder.internal.scalarEg(nu,z)),...
        @scalar_besselj,nu,z,scale);
    else
        w=coder.internal.applyBinaryScalarFunction(mfilename,...
        complex(coder.internal.scalarEg(nu,z)),...
        @scalar_besselj,nu,z);
    end



    function w=scalar_besselj(nu,z,scale)
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
        elseif dnu>0
            [w,~,ierr]=cbesj(zd,dnu,kode);
        elseif dnu==fixnu&&~isinf(dnu)
            [w,~,ierr]=cbesj(zd,-dnu,kode);
            if mod(dnu,2)~=0
                w=-w;
            end
        elseif zd==0
            w=complex(coder.internal.inf);
        else
            [w,~,ierr]=cbesj(zd,-dnu,kode);
            w=ierrCheckAndModify(ierr,w);
            [w2,~,ierr]=cbesy(zd,-dnu,kode);
            NUrem2=rem(-dnu,2);
            [c,s]=coder.internal.scalar.cospiAndSinpi(NUrem2);
            w=c*w-s*w2;
        end
        w=ierrCheckAndModify(ierr,w);
        if(isreal(zd)||imag(zd)==0)&&(real(zd)>0||dnu==fixnu)
            w(1)=real(w);
        end


