function w=besselk(nu,z,scale)











%#codegen

    coder.allowpcode('plain');
    narginchk(2,3);
    coder.internal.prefer_const(nu);
    coder.internal.assert(isfloat(nu)&&isfloat(z),...
    'MATLAB:besselk:nonFloatInput');
    coder.internal.assert(isreal(nu),...
    'MATLAB:besselk:nonRealNU');
    coder.internal.assert(~issparse(nu)&&~issparse(z),...
    'MATLAB:besselk:sparseInput');


    if nargin==3
        coder.internal.prefer_const(scale);
        coder.internal.assert(isfloat(scale),...
        'MATLAB:besselk:nonFloatInput');
        coder.internal.assert(isscalar(scale)&&isreal(scale)&&...
        (scale==0||scale==1),...
        'MATLAB:besselk:ScaleNotZeroOrOne');
        w=coder.internal.applyBinaryScalarFunction(mfilename,...
        complex(coder.internal.scalarEg(nu,z)),...
        @scalar_besselk,nu,z,scale);
    else
        w=coder.internal.applyBinaryScalarFunction(mfilename,...
        complex(coder.internal.scalarEg(nu,z)),...
        @scalar_besselk,nu,z);
    end



    function w=scalar_besselk(nu,z,scale)
        coder.internal.prefer_const(nu);
        dnu=double(nu);



        zd=complex(double(z));
        if nargin<3
            kode=int32(1);
        else
            coder.internal.prefer_const(scale);
            kode=int32(scale+1);
        end
        if isnan(dnu)||isnan(zd)
            w=complex(coder.internal.nan);
        elseif z==0
            w=complex(coder.internal.inf);
        else
            [w,~,ierr]=cbesk(zd,abs(dnu),kode);
            if real(zd)>0&&imag(zd)==0
                w=complex(real(w));
            end
            w=ierrCheckAndModify(ierr,w);
        end



