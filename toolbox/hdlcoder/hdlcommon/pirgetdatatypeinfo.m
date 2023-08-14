function tpinfo=pirgetdatatypeinfo(hT,forceFixdtType)









    if nargin==1
        forceFixdtType=false;
    end

    tpinfo.iscomplex=0;
    tpinfo.numdims=1;
    tpinfo.dims=1;
    tpinfo.isscalar=1;
    tpinfo.isvector=0;
    tpinfo.ismatrix=0;
    tpinfo.vector=0;
    tpinfo.isrowvec=0;
    tpinfo.iscolvec=0;
    tpinfo.isdouble=0;
    tpinfo.issingle=0;
    tpinfo.ishalf=0;
    tpinfo.isfloat=0;








    tpinfo.isnative=1;

    switch hT.ClassName
    case 'tp_double'
        tpinfo.sltype='double';
        tpinfo.issigned=1;
        tpinfo.wordsize=64;
        tpinfo.binarypoint=52;
        tpinfo.isdouble=1;
        tpinfo.isfloat=1;

    case 'tp_single'
        tpinfo.sltype='single';
        tpinfo.issigned=1;
        tpinfo.wordsize=32;
        tpinfo.binarypoint=23;
        tpinfo.issingle=1;
        tpinfo.isfloat=1;

    case 'tp_half'
        tpinfo.sltype='half';
        tpinfo.issigned=1;
        tpinfo.wordsize=16;
        tpinfo.binarypoint=10;
        tpinfo.ishalf=1;
        tpinfo.isfloat=1;
        tpinfo.isnative=0;

    case 'tp_char'
        wlen=hT.WordLength;
        tpinfo.wordsize=wlen;
        tpinfo.issigned=0;
        tpinfo.binarypoint=0;
        tpinfo.isnative=0;
        tpinfo.sltype='str';

    case 'tp_boolean'
        tpinfo.sltype='boolean';
        tpinfo.wordsize=1;
        tpinfo.issigned=0;
        tpinfo.binarypoint=0;

    case 'tp_logic'
        wlen=hT.WordLength;
        tpinfo.wordsize=wlen;
        tpinfo.issigned=0;
        tpinfo.binarypoint=0;

        if wlen==1
            tpinfo.sltype='boolean';
        else
            tpinfo.isnative=0;
            tpinfo.sltype=tostringInternalSlName(numerictype(false,wlen,0));
        end

    case 'tp_signed'
        wlen=hT.WordLength;
        tpinfo.wordsize=wlen;
        tpinfo.issigned=1;
        tpinfo.binarypoint=0;

        if forceFixdtType
            tpinfo.isnative=0;
            tpinfo.sltype=tostringInternalFixdt(numerictype(true,wlen,0));
        else
            if~ismember(wlen,[8,16,32])
                tpinfo.isnative=0;
            end
            tpinfo.sltype=tostringInternalSlName(numerictype(true,wlen,0));
        end
    case 'tp_unsigned'
        wlen=hT.WordLength;
        tpinfo.wordsize=wlen;
        tpinfo.issigned=0;
        tpinfo.binarypoint=0;

        if forceFixdtType
            tpinfo.isnative=0;
            tpinfo.sltype=tostringInternalFixdt(numerictype(false,wlen,0));
        else
            if~ismember(wlen,[8,16,32])
                tpinfo.isnative=0;
            end
            tpinfo.sltype=tostringInternalSlName(numerictype(false,wlen,0));
        end

    case 'tp_sfixpt'
        wlen=hT.WordLength;
        flen=hT.FractionLength;
        tpinfo.wordsize=wlen;
        tpinfo.binarypoint=flen;
        tpinfo.issigned=1;
        tpinfo.isnative=0;



        tpinfo.sltype=tostringInternalSlName(numerictype(true,wlen,-flen));

    case 'tp_ufixpt'
        wlen=hT.WordLength;
        flen=hT.FractionLength;
        tpinfo.wordsize=wlen;
        tpinfo.binarypoint=flen;
        tpinfo.issigned=0;
        tpinfo.isnative=0;



        tpinfo.sltype=tostringInternalSlName(numerictype(false,wlen,-flen));

    case 'tp_complex'
        hRealT=hT.BaseType;
        tpinfo=pirgetdatatypeinfo(hRealT);
        tpinfo.iscomplex=1;

    case 'tp_array'
        numdims=hT.NumberOfDimensions;
        hBT=hT.BaseType;
        tpinfo=pirgetdatatypeinfo(hBT);
        tpinfo.numdims=numdims;
        tpinfo.dims=hT.Dimensions;
        tpinfo.isscalar=0;
        if numdims==1
            tpinfo.isvector=1;
            tpinfo.ismatrix=0;
        else
            tpinfo.isvector=0;
            tpinfo.ismatrix=1;
        end

        d=tpinfo.dims;
        if tpinfo.numdims==1
            tpinfo.vector=[d,0];
        else
            tpinfo.vector=d;
        end

        if hT.isRowVector
            tpinfo.isrowvec=1;
        end
        if hT.isColumnVector
            tpinfo.iscolvec=1;
        end

    case 'tp_record'



        tpinfo.sltype='bus';
        tpinfo.isscalar=1;
        tpinfo.isvector=0;
        tpinfo.ismatrix=0;
        tpinfo.wordsize=0;
        tpinfo.issigned=0;
        tpinfo.binarypoint=0;
        tpinfo.isdouble=0;
        tpinfo.isnative=0;

    case 'tp_enum'
        tpinfo.sltype=['Enum: ',hT.name];
        tpinfo.wordsize=ceil(log2(length(hT.EnumValues)));
        tpinfo.issigned=1;
        tpinfo.binarypoint=0;
    case 'tp_name'
        tpinfo.sltype=['Name: ',hT.name];

    otherwise
        error(message('hdlcommon:hdlcommon:unhandleddatatype',hT.ClassName));

    end
end


