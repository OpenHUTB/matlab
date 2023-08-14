function w=besseli(nu,z,scale)











%#codegen

    coder.allowpcode('plain');
    narginchk(2,3);
    coder.internal.prefer_const(nu);
    coder.internal.assert(isfloat(nu)&&isfloat(z),...
    'MATLAB:besseli:nonFloatInput');
    coder.internal.assert(isreal(nu),...
    'MATLAB:besseli:nonRealNU');
    coder.internal.assert(~issparse(nu)&&~issparse(z),...
    'MATLAB:besseli:sparseInput');


    if nargin==3
        coder.internal.prefer_const(scale);
        coder.internal.assert(isfloat(scale),...
        'MATLAB:besseli:nonFloatInput');
        coder.internal.assert(isscalar(scale)&&isreal(scale)&&...
        (scale==0||scale==1),...
        'MATLAB:besseli:ScaleNotZeroOrOne');
        w=coder.internal.applyBinaryScalarFunction(mfilename,...
        complex(coder.internal.scalarEg(nu,z)),...
        @scalar_besseli,nu,z,scale);
    else
        w=coder.internal.applyBinaryScalarFunction(mfilename,...
        complex(coder.internal.scalarEg(nu,z)),...
        @scalar_besseli,nu,z);
    end



    function w=scalar_besseli(nu,z,scale)
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
            return
        end
        ierr=int32(0);
        fixnu=fix(dnu);
        if dnu>=0
            [w,~,ierr]=cbesi(zd,dnu,kode);
        elseif dnu==fixnu&&~isinf(dnu)
            [w,~,ierr]=cbesi(zd,-dnu,kode);
        elseif z==0
            w=complex(coder.internal.inf);
        else
            [w,~,ierr]=cbesi(zd,-dnu,kode);
            w=ierrCheckAndModify(ierr,w);
            [w2,~,ierr]=cbesk(zd,-dnu,int32(1));
            a=(2/pi)*sinpi(dnu);
            if kode==1
                w=w-a*w2;
            else
                aExp=a*exp(-abs(real(zd)));
                w=w-aExp*w2;
            end
        end
        w=ierrCheckAndModify(ierr,w);
        if(isreal(z)||imag(zd)==0)&&real(zd)>0
            w(1)=real(w);
        end


