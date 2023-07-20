function w=airy(order,z,scale)











%#codegen

    coder.allowpcode('plain');
    narginchk(1,3);
    if nargin==1
        coder.inline('always');
        w=airy(0,order,0);
        return
    elseif nargin==2
        coder.inline('always');
        w=airy(order,z,0);
        return
    end
    coder.internal.prefer_const(order,scale);
    coder.internal.assert(isfloat(order),...
    'MATLAB:airy:nonFloatInput');
    coder.internal.assert(isscalar(order)&&isreal(order),...
    'MATLAB:airy:InvalidOrder');
    coder.internal.assert(order==0||order==1||order==2||order==3,...
    'MATLAB:airy:InvalidOrder');
    iorder=cast(order,'int32');
    coder.internal.assert(isfloat(scale),...
    'MATLAB:airy:nonFloatInput');
    coder.internal.assert(isscalar(scale)&&isreal(scale)&&...
    (scale==0||scale==1),...
    'MATLAB:airy:InvalidScale');
    kode=int32(scale+1);
    coder.internal.assert(isfloat(z),...
    'MATLAB:airy:nonFloatInput');
    coder.internal.assert(~issparse(z),...
    'MATLAB:airy:sparseInput');
    w=coder.internal.applyBinaryScalarFunction(mfilename,...
    complex(coder.internal.scalarEg(z)),...
    @scalar_airy,iorder,z,kode);



    function w=scalar_airy(order,z,kode)
        coder.internal.prefer_const(order,kode);



        dz=complex(double(z));
        if isnan(dz)
            w=complex(coder.internal.nan);
            return
        end
        if order==0||order==1
            [w,~,ierr]=cairy(dz,order,kode);
            w=ierrCheckAndModify(ierr,w);
            if(isreal(z)||imag(z)==0)&&(kode==1||real(z)>=0)
                w(1)=real(w);
            end
        else
            [w,ierr]=cbiry(dz,order-2,kode);
            w=ierrCheckAndModify(ierr,w);
            if isreal(z)||imag(z)==0
                w(1)=real(w);
            end
        end


