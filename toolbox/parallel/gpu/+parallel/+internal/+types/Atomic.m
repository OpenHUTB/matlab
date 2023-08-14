classdef Atomic










    enumeration





        d('double',true,false,true,false,true,true,false)
        D('array double',false,false,true,false,true,true,false)
        f('single',true,false,true,false,true,true,false)
        F('array single',false,false,true,false,true,true,false)
        cd('complex double',true,true,true,false,true,true,false)
        CD('array complex double',false,true,true,false,true,true,false)
        cf('complex single',true,true,true,false,true,true,false)
        CF('array complex single',false,true,true,false,true,true,false)



        c('int8',true,false,false,true,true,true,false)
        C('array int8',false,false,false,true,true,true,false)
        h('uint8',true,false,false,true,false,true,false)
        H('array uint8',false,false,false,true,false,true,false)
        s('int16',true,false,false,true,true,true,false)
        S('array int16',false,false,false,true,true,true,false)
        t('uint16',true,false,false,true,false,true,false)
        T('array uint16',false,false,false,true,false,true,false)
        i('int32',true,false,false,true,true,true,false)
        I('array int32',false,false,false,true,true,true,false)
        j('uint32',true,false,false,true,false,true,false)
        J('array uint32',false,false,false,true,false,true,false)
        l('int64',true,false,false,true,true,true,false)
        L('array int64',false,false,false,true,true,true,false)
        m('uint64',true,false,false,true,false,true,false)
        M('array uint64',false,false,false,true,false,true,false)
        cc('complex int8',true,true,false,true,true,true,false)
        CC('array complex int8',false,true,false,true,true,true,false)
        ch('complex uint8',true,true,false,true,false,true,false)
        CH('array complex uint8',false,true,false,true,false,true,false)
        cs('complex int16',true,true,false,true,true,true,false)
        CS('array complex int16',false,true,false,true,true,true,false)
        ct('complex uint16',true,true,false,true,false,true,false)
        CT('array complex uint16',false,true,false,true,false,true,false)
        ci('complex int32',true,true,false,true,true,true,false)
        CI('array complex int32',false,true,false,true,true,true,false)
        cj('complex uint32',true,true,false,true,false,true,false)
        CJ('array complex uint32',false,true,false,true,false,true,false)
        cl('complex int64',true,true,false,true,true,true,false)
        CL('array complex int64',false,true,false,true,true,true,false)
        cm('complex uint64',true,true,false,true,false,true,false)
        CM('array complex uint64',false,true,false,true,false,true,false)



        b('logical',true,false,false,false,false,true,false)
        B('array logical',false,false,false,false,false,true,false)

        Null('null',false,false,false,false,true,true,false)



        ECI('complex/integer interaction',false,false,false,false,false,false,false)
        EFI('floatingpoint/integer interaction',false,false,false,false,false,false,false)
        EMI('mismatched integers',false,false,false,false,false,false,false)
        EUT('unsupported type',false,false,false,false,false,false,false)
        EUC('unsupported complexity',false,false,false,false,false,false,false)
        EUL('unsupported logical operation',false,false,false,false,false,false,false)
        ERS('requires scalar inputs',false,false,false,false,false,false,false)
        EA('assert',false,false,false,false,false,false,false)



        y('char',true,false,false,true,true,false,false)
        Y('array char',false,false,false,true,true,false,false)

        ce('cell',false,false,false,false,false,false,false)
        st('struct',false,false,false,false,false,false,false)
        mcos('mcos',false,false,false,false,false,false,false)
        fh('function_handle',false,false,false,false,false,false,false)




        j4('uint4',true,false,false,true,false,false,false)
        ll3('longlong3',true,false,false,true,true,false,false)
        ll4('ulong4',true,false,false,true,false,false,false)

    end

    properties(GetAccess=private,SetAccess=immutable)
fMType
fIsScalar
fIsComplex
fIsFloat
fIsInteger
fIsSigned
fIsSupported
fIsSparse
    end

    methods
        function obj=Atomic(mtype,isScalar,isComplex,...
            isFloat,isInteger,isSigned,...
            isSupported,isSparse)


            mlock;


            obj.fMType=mtype;
            obj.fIsScalar=isScalar;
            obj.fIsComplex=isComplex;
            obj.fIsFloat=isFloat;
            obj.fIsInteger=isInteger;
            obj.fIsSigned=isSigned;
            obj.fIsSupported=isSupported;
            obj.fIsSparse=isSparse;
        end
    end


    methods(Static=true,Hidden=true)


        function validateIsScalar(obj)
            assert(numel(obj)==1,'validateinput:nonscalar','only scalars can be processed');
        end


        function otype=buildAtomic(input,arrayp)

            switch input
            case 'double'
                otype=parallel.internal.types.Atomic.d;
                if arrayp,otype=parallel.internal.types.Atomic.D;end
            case 'single'
                otype=parallel.internal.types.Atomic.f;
                if arrayp,otype=parallel.internal.types.Atomic.F;end
            case 'int32'
                otype=parallel.internal.types.Atomic.i;
                if arrayp,otype=parallel.internal.types.Atomic.I;end
            case 'uint32'
                otype=parallel.internal.types.Atomic.j;
                if arrayp,otype=parallel.internal.types.Atomic.J;end
            case 'logical'
                otype=parallel.internal.types.Atomic.b;
                if arrayp,otype=parallel.internal.types.Atomic.B;end
            case 'complex double'
                otype=parallel.internal.types.Atomic.cd;
                if arrayp,otype=parallel.internal.types.Atomic.CD;end
            case 'complex single'
                otype=parallel.internal.types.Atomic.cf;
                if arrayp,otype=parallel.internal.types.Atomic.CF;end
            case 'int64'
                otype=parallel.internal.types.Atomic.l;
                if arrayp,otype=parallel.internal.types.Atomic.L;end
            case 'uint64'
                otype=parallel.internal.types.Atomic.m;
                if arrayp,otype=parallel.internal.types.Atomic.M;end
            case 'int16'
                otype=parallel.internal.types.Atomic.s;
                if arrayp,otype=parallel.internal.types.Atomic.S;end
            case 'uint16'
                otype=parallel.internal.types.Atomic.t;
                if arrayp,otype=parallel.internal.types.Atomic.T;end
            case 'int8'
                otype=parallel.internal.types.Atomic.c;
                if arrayp,otype=parallel.internal.types.Atomic.C;end
            case 'uint8'
                otype=parallel.internal.types.Atomic.h;
                if arrayp,otype=parallel.internal.types.Atomic.H;end
            case 'char'
                otype=parallel.internal.types.Atomic.y;
                if arrayp,otype=parallel.internal.types.Atomic.Y;end
            case 'complex int64'
                otype=parallel.internal.types.Atomic.cl;
                if arrayp,otype=parallel.internal.types.Atomic.CL;end
            case 'complex uint64'
                otype=parallel.internal.types.Atomic.cm;
                if arrayp,otype=parallel.internal.types.Atomic.CM;end
            case 'complex int32'
                otype=parallel.internal.types.Atomic.ci;
                if arrayp,otype=parallel.internal.types.Atomic.CI;end
            case 'complex uint32'
                otype=parallel.internal.types.Atomic.cj;
                if arrayp,otype=parallel.internal.types.Atomic.CJ;end
            case 'complex int16'
                otype=parallel.internal.types.Atomic.cs;
                if arrayp,otype=parallel.internal.types.Atomic.CS;end
            case 'complex uint16'
                otype=parallel.internal.types.Atomic.ct;
                if arrayp,otype=parallel.internal.types.Atomic.CT;end
            case 'complex int8'
                otype=parallel.internal.types.Atomic.cc;
                if arrayp,otype=parallel.internal.types.Atomic.CC;end
            case 'complex uint8'
                otype=parallel.internal.types.Atomic.ch;
                if arrayp,otype=parallel.internal.types.Atomic.CH;end
            case 'cell'
                otype=parallel.internal.types.Atomic.ce;
            case 'struct'
                otype=parallel.internal.types.Atomic.st;
            case 'mcos'
                otype=parallel.internal.types.Atomic.mcos;
            case 'function_handle'
                otype=parallel.internal.types.Atomic.fh;
            case 'uint128'
                otype=parallel.internal.types.Atomic.j4;
            case 'uint196'
                otype=parallel.internal.types.Atomic.ll3;
            case 'uint256'
                otype=parallel.internal.types.Atomic.ll4;
            otherwise
                assert(false,'buildtype:unknown','unknown class: ''%s''',input);
            end

        end


        function otype=enumerate(input)

            inputClass=class(input);

            arrayp=isempty(input)||(numel(input)>1);

            if isobject(input)
                if isa(input,'gpuArray')
                    inputClass=underlyingType(input);
                    if~isreal(input)
                        inputClass=['complex ',inputClass];
                    end
                else
                    inputClass='mcos';
                end
            elseif~isreal(input)&&isnumeric(input)
                inputClass=['complex ',inputClass];
            end

            otype=parallel.internal.types.Atomic.buildAtomic(inputClass,arrayp);

        end

    end


    methods(Hidden=true)






        function out=mType(obj)
            parallel.internal.types.Atomic.validateIsScalar(obj);
            out=obj.fMType;
        end


        function ctype=cType(obj)
            parallel.internal.types.Atomic.validateIsScalar(obj);
            switch char(obj)
            case 'd',ctype='double';
            case 'f',ctype='float';
            case 'i',ctype='int';
            case 'j',ctype='unsigned int';
            case 's',ctype='short';
            case 't',ctype='unsigned short';
            case 'c',ctype='signed char';
            case 'h',ctype='unsigned char';
            case 'l',ctype='long';
            case 'm',ctype='unsigned long';
            case 'b',ctype='bool';
            case 'cd',ctype='double2';
            case 'cf',ctype='float2';
            case 'ci',ctype='int2';
            case 'cj',ctype='uint2';
            case 'cs',ctype='short2';
            case 'ct',ctype='ushort2';
            case 'cc',ctype='char2';
            case 'ch',ctype='uchar2';
            case 'cl',ctype='long2';
            case 'cm',ctype='ulong2';
            case 'D',ctype='double *';
            case 'F',ctype='float *';
            case 'I',ctype='int *';
            case 'J',ctype='unsigned int *';
            case 'S',ctype='short *';
            case 'T',ctype='unsigned short *';
            case 'C',ctype='signed char *';
            case 'H',ctype='unsigned char *';
            case 'L',ctype='long *';
            case 'M',ctype='unsigned long *';
            case 'B',ctype='bool *';
            case 'CD',ctype='double2 *';
            case 'CF',ctype='float2 *';
            case 'CI',ctype='int2 *';
            case 'CJ',ctype='uint2 *';
            case 'CS',ctype='short2 *';
            case 'CT',ctype='ushort2 *';
            case 'CC',ctype='char2 *';
            case 'CH',ctype='uchar2 *';
            case 'CL',ctype='long2 *';
            case 'CM',ctype='ulong2 *';
            case 'j4',ctype='uint4';
            case 'll3',ctype='longlong3';
            case 'll4',ctype='ulong4';
            otherwise
                assert(false,'unknown type encoding ''%s''',char(obj));
            end
        end


        function display(obj)%#ok<DISPLAY>
            N=numel(obj);
            for kk=1:N
                display(mType(obj(kk)));
            end
        end


        function key=makeKey(obj)
            key=char(obj);
        end

        function nbits=nonSignBits(obj)

            parallel.internal.types.Atomic.validateIsScalar(obj);
            realType=coerceReal(obj);
            switch char(realType)
            case{'d','D'},nbits=63;
            case{'f','F'},nbits=31;
            case{'i','I'},nbits=31;
            case{'j','J'},nbits=32;
            case{'s','S'},nbits=15;
            case{'t','T'},nbits=16;
            case{'c','C'},nbits=7;
            case{'b','B'},nbits=32;
            case{'h','H'},nbits=8;
            case{'l','L'},nbits=63;
            case{'m','M'},nbits=64;
            otherwise
                assert(false,'invalid non sign bits, problem with ''%s''',mType(obj));
            end

        end




        function out=isSupported(obj)
            out=obj.fIsSupported;
        end

        function samep=isSameBaseType(obj,type)

            samep=(coerceScalar(obj)==coerceScalar(type));

        end

        function out=isSparse(obj)
            out=obj.fIsSparse;
        end




        function doublep=isDouble(obj)
            switch char(obj)
            case{'d','D'}
                doublep=true;
            otherwise
                doublep=false;
            end
        end

        function singlep=isSingle(obj)
            switch char(obj)
            case{'f','F'}
                singlep=true;
            otherwise
                singlep=false;
            end
        end

        function complexdoublep=isComplexDouble(obj)
            switch char(obj)
            case{'cd','CD'}
                complexdoublep=true;
            otherwise
                complexdoublep=false;
            end
        end

        function complexsinglep=isComplexSingle(obj)
            switch char(obj)
            case{'cf','CF'}
                complexsinglep=true;
            otherwise
                complexsinglep=false;
            end
        end

        function int64p=isInt64(obj)
            switch char(obj)
            case{'l','L'}
                int64p=true;
            otherwise
                int64p=false;
            end
        end

        function uint64p=isUint64(obj)
            switch char(obj)
            case{'m','M'}
                uint64p=true;
            otherwise
                uint64p=false;
            end
        end

        function int64p=isComplexInt64(obj)
            switch char(obj)
            case{'cl','CL'}
                int64p=true;
            otherwise
                int64p=false;
            end
        end

        function uint64p=isComplexUint64(obj)
            switch char(obj)
            case{'cm','CM'}
                uint64p=true;
            otherwise
                uint64p=false;
            end
        end

        function int32p=isInt32(obj)
            switch char(obj)
            case{'i','I'}
                int32p=true;
            otherwise
                int32p=false;
            end
        end

        function uint32p=isUint32(obj)
            switch char(obj)
            case{'j','J'}
                uint32p=true;
            otherwise
                uint32p=false;
            end
        end

        function int32p=isComplexInt32(obj)
            switch char(obj)
            case{'ci','CI'}
                int32p=true;
            otherwise
                int32p=false;
            end
        end

        function uint32p=isComplexUint32(obj)
            switch char(obj)
            case{'cj','CJ'}
                uint32p=true;
            otherwise
                uint32p=false;
            end
        end

        function int32p=isInt16(obj)
            switch char(obj)
            case{'s','S'}
                int32p=true;
            otherwise
                int32p=false;
            end
        end

        function uint32p=isUint16(obj)
            switch char(obj)
            case{'t','T'}
                uint32p=true;
            otherwise
                uint32p=false;
            end
        end

        function int32p=isComplexInt16(obj)
            switch char(obj)
            case{'cs','CS'}
                int32p=true;
            otherwise
                int32p=false;
            end
        end

        function uint32p=isComplexUint16(obj)
            switch char(obj)
            case{'ct','CT'}
                uint32p=true;
            otherwise
                uint32p=false;
            end
        end

        function int8p=isInt8(obj)
            switch char(obj)
            case{'c','C'}
                int8p=true;
            otherwise
                int8p=false;
            end
        end

        function uint8p=isUint8(obj)
            switch char(obj)
            case{'h','H'}
                uint8p=true;
            otherwise
                uint8p=false;
            end
        end

        function int32p=isComplexInt8(obj)
            switch char(obj)
            case{'cc','CC'}
                int32p=true;
            otherwise
                int32p=false;
            end
        end

        function uint32p=isComplexUint8(obj)
            switch char(obj)
            case{'ch','CH'}
                uint32p=true;
            otherwise
                uint32p=false;
            end
        end

        function logicalp=isLogical(obj)
            switch char(obj)
            case{'b','B'}
                logicalp=true;
            otherwise
                logicalp=false;
            end
        end

        function charp=isChar(obj)
            switch char(obj)
            case{'y','Y'}
                charp=true;
            otherwise
                charp=false;
            end
        end

        function nullp=isNull(obj)
            nullp=strcmp('Null',char(obj));
        end

        function ll3p=isLongLong3(obj)
            ll3p=strcmp('ll3',char(obj));
        end






        function out=isArray(obj)

            numericOrLogical=isNumeric(obj)||isLogical(obj);
            out=numericOrLogical&&~obj.fIsScalar;
        end

        function out=isScalar(obj)
            out=obj.fIsScalar;
        end

        function out=isNumeric(obj)
            out=obj.fIsFloat||obj.fIsInteger;
        end

        function out=isFloatingPoint(obj)
            out=obj.fIsFloat;
        end

        function out=isReal(obj)
            out=~obj.fIsComplex;
        end

        function out=isRealFloatingPoint(obj)
            out=obj.fIsFloat&&~obj.fIsComplex;
        end

        function out=isComplexFloatingPoint(obj)
            out=obj.fIsFloat&&obj.fIsComplex;
        end

        function out=isInteger(obj)
            out=obj.fIsInteger;
        end

        function out=isRealInteger(obj)
            out=obj.fIsInteger&&~obj.fIsComplex;
        end

        function out=isSignedInteger(obj)
            out=obj.fIsInteger&&obj.fIsSigned;
        end

        function out=isUnsignedInteger(obj)
            out=obj.fIsInteger&&~obj.fIsSigned;
        end

        function out=isSupportedInteger(obj)
            out=obj.fIsSupported&&obj.fIsInteger;
        end

        function complexp=isComplex(obj)
            complexp=obj.fIsComplex;
        end

        function out=is64BitInteger(obj)
            out=isInt64(obj)||isUint64(obj);
        end

        function errorp=isError(obj)
            switch char(obj)
            case{'ECI','EFI','EMI','EUT','EUL','EA'}
                errorp=true;
            otherwise
                errorp=false;
            end
        end






        function otype=resolveTypes(obj,type)
            otype=type;
            if isArray(obj)
                otype=coerceArray(otype);
            end
        end

        function otype=coerceDouble(obj)
            if isArray(obj)
                otype=parallel.internal.types.Atomic.D;
            else
                otype=parallel.internal.types.Atomic.d;
            end
        end

        function otype=coerceSingle(obj)
            if isArray(obj)
                otype=parallel.internal.types.Atomic.F;
            else
                otype=parallel.internal.types.Atomic.f;
            end
        end

        function otype=coerceComplexDouble(obj)
            if isArray(obj)
                otype=parallel.internal.types.Atomic.CD;
            else
                otype=parallel.internal.types.Atomic.cd;
            end
        end

        function otype=coerceComplexSingle(obj)
            if isArray(obj)
                otype=parallel.internal.types.Atomic.CF;
            else
                otype=parallel.internal.types.Atomic.cf;
            end
        end

        function otype=coerceInt32(obj)
            if isArray(obj)
                otype=parallel.internal.types.Atomic.I;
            else
                otype=parallel.internal.types.Atomic.i;
            end
        end

        function otype=coerceUint32(obj)
            if isArray(obj)
                otype=parallel.internal.types.Atomic.J;
            else
                otype=parallel.internal.types.Atomic.j;
            end
        end

        function otype=coerceInt16(obj)
            if isArray(obj)
                otype=parallel.internal.types.Atomic.S;
            else
                otype=parallel.internal.types.Atomic.s;
            end
        end

        function otype=coerceUint16(obj)
            if isArray(obj)
                otype=parallel.internal.types.Atomic.T;
            else
                otype=parallel.internal.types.Atomic.t;
            end
        end

        function otype=coerceInt8(obj)
            if isArray(obj)
                otype=parallel.internal.types.Atomic.C;
            else
                otype=parallel.internal.types.Atomic.c;
            end
        end

        function otype=coerceUint8(obj)
            if isArray(obj)
                otype=parallel.internal.types.Atomic.h;
            else
                otype=parallel.internal.types.Atomic.H;
            end
        end

        function otype=coerceLogical(obj)
            if isArray(obj)
                otype=parallel.internal.types.Atomic.B;
            else
                otype=parallel.internal.types.Atomic.b;
            end
        end

        function otype=coerceComplex(obj)
            if obj.fIsComplex
                otype=obj;
                return
            end

            switch char(obj)
            case 'd'
                otype=parallel.internal.types.Atomic.cd;
            case 'D'
                otype=parallel.internal.types.Atomic.CD;
            case 'f'
                otype=parallel.internal.types.Atomic.cf;
            case 'F'
                otype=parallel.internal.types.Atomic.CF;
            case 'i'
                otype=parallel.internal.types.Atomic.ci;
            case 'I'
                otype=parallel.internal.types.Atomic.CI;
            case 'j'
                otype=parallel.internal.types.Atomic.cj;
            case 'J'
                otype=parallel.internal.types.Atomic.CJ;
            case 's'
                otype=parallel.internal.types.Atomic.cs;
            case 'S'
                otype=parallel.internal.types.Atomic.CS;
            case 't'
                otype=parallel.internal.types.Atomic.ct;
            case 'T'
                otype=parallel.internal.types.Atomic.CT;
            case 'c'
                otype=parallel.internal.types.Atomic.cc;
            case 'C'
                otype=parallel.internal.types.Atomic.CC;
            case 'h'
                otype=parallel.internal.types.Atomic.ch;
            case 'H'
                otype=parallel.internal.types.Atomic.CH;
            case 'l'
                otype=parallel.internal.types.Atomic.cl;
            case 'L'
                otype=parallel.internal.types.Atomic.CL;
            case 'm'
                otype=parallel.internal.types.Atomic.cm;
            case 'M'
                otype=parallel.internal.types.Atomic.CM;
            otherwise
                assert(false,'Atomic:coerce:complex',...
                'unsupported coercion of ''%s'' to complex',mType(obj));
            end
        end

        function otype=coerceReal(obj)
            if~obj.fIsComplex
                otype=obj;
                return;
            end

            switch char(obj)
            case 'cd'
                otype=parallel.internal.types.Atomic.d;
            case 'CD'
                otype=parallel.internal.types.Atomic.D;
            case 'cf'
                otype=parallel.internal.types.Atomic.f;
            case 'CF'
                otype=parallel.internal.types.Atomic.F;
            case 'ci'
                otype=parallel.internal.types.Atomic.i;
            case 'CI'
                otype=parallel.internal.types.Atomic.I;
            case 'cj'
                otype=parallel.internal.types.Atomic.j;
            case 'CJ'
                otype=parallel.internal.types.Atomic.J;
            case 'cs'
                otype=parallel.internal.types.Atomic.s;
            case 'CS'
                otype=parallel.internal.types.Atomic.S;
            case 'ct'
                otype=parallel.internal.types.Atomic.t;
            case 'CT'
                otype=parallel.internal.types.Atomic.T;
            case 'cc'
                otype=parallel.internal.types.Atomic.c;
            case 'CC'
                otype=parallel.internal.types.Atomic.C;
            case 'ch'
                otype=parallel.internal.types.Atomic.h;
            case 'CH'
                otype=parallel.internal.types.Atomic.H;
            case 'cl'
                otype=parallel.internal.types.Atomic.l;
            case 'CL'
                otype=parallel.internal.types.Atomic.L;
            case 'cm'
                otype=parallel.internal.types.Atomic.m;
            case 'CM'
                otype=parallel.internal.types.Atomic.M;
            otherwise
                assert(false,'Atomic:coerce:real',...
                'unsupported coercion of ''%s'' to real',mType(obj));
            end
        end

        function otype=coerceArray(obj)
            otype=parallel.internal.types.Atomic.(upper(char(obj)));
        end

        function otype=coerceScalar(obj)
            otype=parallel.internal.types.Atomic.(lower(char(obj)));
        end


    end


end


