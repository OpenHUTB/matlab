function w=besselh(nu,k,z,scale)











%#codegen

    coder.allowpcode('plain');
    narginchk(2,4);
    coder.internal.prefer_const(nu);


    if nargin==2
        validate(nu,1,k,0);
        w=coder.internal.applyBinaryScalarFunction(mfilename,...
        complex(coder.internal.scalarEg(nu,k)),...
        @scalar_besselh,nu,k,1,0);
    elseif nargin==3
        coder.internal.prefer_const(k);
        validate(nu,k,z,0);
        w=coder.internal.applyBinaryScalarFunction(mfilename,...
        complex(coder.internal.scalarEg(nu,k)),...
        @scalar_besselh,nu,z,k,0);
    else
        coder.internal.prefer_const(scale);
        validate(nu,k,z,scale);
        w=coder.internal.applyBinaryScalarFunction(mfilename,...
        complex(coder.internal.scalarEg(nu,k,z)),...
        @scalar_besselh,nu,z,k,scale);
    end



    function validate(nu,k,z,scale)
        coder.internal.prefer_const(nu,k,scale);
        coder.internal.assert(isfloat(z),'MATLAB:besselh:nonFloatInput');
        coder.internal.assert(~issparse(nu)&&~issparse(k)&&...
        ~issparse(z)&&~issparse(scale),'MATLAB:besselh:sparseInput');
        coder.internal.assert(isfloat(k),'MATLAB:besselh:nonFloatInput');
        coder.internal.assert(isscalar(k)&&isreal(k)&&(k==1||k==2),...
        'MATLAB:besselh:KNotOneOrTwo');
        coder.internal.assert(isfloat(nu),'MATLAB:besselh:nonFloatInput');
        coder.internal.assert(isreal(nu),'MATLAB:besselh:nonRealNU');
        coder.internal.assert(isfloat(scale),'MATLAB:besselh:nonFloatInput');
        coder.internal.assert(isscalar(scale)&&isreal(scale)&&...
        (scale==0||scale==1),...
        'MATLAB:besselh:ScaleNotZeroOrOne');



        function w=scalar_besselh(nu,z,k,scale)
            coder.internal.prefer_const(nu,k,scale);
            THRESH=sqrt(eps);
            nud=double(nu);
            fixnud=fix(nud);



            zd=complex(double(z));
            kode=int32(scale+1);
            if isnan(nud)||isnan(zd)
                w=complex(coder.internal.nan);
            else
                [w,~,ierr]=cbesh(zd,abs(nud),kode,k);







                if(kode==1)&&...
                    (imag(zd)==0&&(real(zd)>0||nud==fixnud))&&...
                    (abs(real(w)/imag(w))<THRESH)
                    w2=besselj(abs(nu),zd,scale);
                    w=complex(real(w2),imag(w));
                end
                if nu<0
                    tmp=rem(nu,2);
                    if tmp~=0
                        if tmp==-1
                            w=-w;
                        else
                            [cosX,sinX]=coder.internal.scalar.cospiAndSinpi(tmp);
                            eiX=complex(cosX,sinX);
                            if k==1
                                w=conj(eiX)*w;
                            else
                                w=eiX*w;
                            end
                        end
                    end
                end
                w=ierrCheckAndModify(ierr,w);
            end


