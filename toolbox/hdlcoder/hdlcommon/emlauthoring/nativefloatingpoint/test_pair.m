function test_pair(A,B)



    [AS,AE,AM]=float32_unpack(A);
    [BS,BE,BM]=float32_unpack(B);
    AF=packed_to_single(A);
    BF=packed_to_single(B);

    [S,E,M]=float32_add(AS,AE,AM,BS,BE,BM,false);
    C=float32_pack(S,E,M);F=packed_to_single(C);
    CF=AF+BF;
    fp32_check_op(A,B,C,single_to_packed(CF),F,CF,'+');

    [S,E,M]=float32_add(AS,AE,AM,BS,BE,BM,true);
    C=float32_pack(S,E,M);F=packed_to_single(C);
    CF=AF+BF;


    [S,E,M]=float32_sub(AS,AE,AM,BS,BE,BM,false);
    C=float32_pack(S,E,M);F=packed_to_single(C);
    CF=AF-BF;
    fp32_check_op(A,B,C,single_to_packed(CF),F,CF,'-');

    [S,E,M]=float32_sub(AS,AE,AM,BS,BE,BM,true);
    C=float32_pack(S,E,M);F=packed_to_single(C);
    CF=AF-BF;


    [S,E,M]=float32_mul(AS,AE,AM,BS,BE,BM,false);
    C=float32_pack(S,E,M);F=packed_to_single(C);
    CF=AF*BF;
    fp32_check_op(A,B,C,single_to_packed(CF),F,CF,'*');

    [S,E,M]=float32_mul(AS,AE,AM,BS,BE,BM,true);
    C=float32_pack(S,E,M);F=packed_to_single(C);
    CF=AF*BF;


    [S,E,M]=float32_div(AS,AE,AM,BS,BE,BM,false);
    C=float32_pack(S,E,M);F=packed_to_single(C);
    CF=AF/BF;
    fp32_check_op(A,B,C,single_to_packed(CF),F,CF,'/');

    [S,E,M]=float32_div(AS,AE,AM,BS,BE,BM,true);
    C=float32_pack(S,E,M);F=packed_to_single(C);
    CF=AF/BF;
    fp32_check_op_nrm(A,B,C,single_to_packed(CF),F,CF,'@/');

    if((AF==BF)~=float32_eq(AS,AE,AM,BS,BE,BM))
        fprintf('emulation: %g == %g = %d\n',AF,BF,int32(AF==BF));
        fprintf('native:    %g == %g = %d\n',AF,BF,int32(float32_eq(AS,AE,AM,BS,BE,BM)));
        error(message('hdlcommon:nativefloatingpoint:NfpEmlAuthoredNumericMismatch','eq'));
    end

    if((AF~=BF)~=float32_ne(AS,AE,AM,BS,BE,BM))
        fprintf('emulation: %g ~= %g = %d\n',AF,BF,int32(AF~=BF));
        fprintf('native:    %g ~= %g = %d\n',AF,BF,int32(float32_ne(AS,AE,AM,BS,BE,BM)));
        error(message('hdlcommon:nativefloatingpoint:NfpEmlAuthoredNumericMismatch','ne'));
    end

    if((AF<BF)~=float32_lt(AS,AE,AM,BS,BE,BM))
        fprintf('emulation: %g < %g = %d\n',AF,BF,int32(AF<BF));
        fprintf('native:    %g < %g = %d\n',AF,BF,int32(float32_lt(AS,AE,AM,BS,BE,BM)));
        error(message('hdlcommon:nativefloatingpoint:NfpEmlAuthoredNumericMismatch','lt'));
    end

    if((AF<=BF)~=float32_le(AS,AE,AM,BS,BE,BM))
        fprintf('emulation: %g <= %g = %d\n',AF,BF,int32(AF<BF));
        fprintf('native:    %g <= %g = %d\n',AF,BF,int32(float32_le(AS,AE,AM,BS,BE,BM)));
        error(message('hdlcommon:nativefloatingpoint:NfpEmlAuthoredNumericMismatch','le'));
    end

    [S,E,M]=uint_to_float32(A);
    AP=float32_pack(S,E,M);
    AF=packed_to_single(AP);
    BF=single(A);
    BP=single_to_packed(BF);
    if((AP~=BP))
        fprintf('emulation: %g = uint32(%u)\n',AF,A);
        fprintf('native:    %g = uint32(%u)\n',BF,A);
        error(message('hdlcommon:nativefloatingpoint:NfpEmlAuthoredNumericMismatch','uint-to-float32'));
    end

    AA=int32(A)-intmax/2;
    [S,E,M]=int_to_float32(AA);
    AP=float32_pack(S,E,M);
    AF=packed_to_single(AP);
    BF=single(AA);
    BP=single_to_packed(BF);
    if((AP~=BP))
        fprintf('emulation: %g = uint32(%d)\n',AF,AA);
        fprintf('native:    %g = uint32(%d)\n',BF,AA);
        error(message('hdlcommon:nativefloatingpoint:NfpEmlAuthoredNumericMismatch','int32(arg1)-intmax/2'));
    end

    AF=packed_to_single(uint32(A));
    [S,E,M]=float32_unpack(A);
    AA=float32_to_uint(S,E,M);
    BB=uint32(fix(AF));

    if((AA~=BB))
        fprintf('emulation: %u = single(%g)\n',AA,AF);
        fprintf('native:    %u = single(%g)\n',BB,AF);
        error(message('hdlcommon:nativefloatingpoint:NfpEmlAuthoredNumericMismatch','packed-to-single'));
    end

    AF=packed_to_single(uint32(A));
    [S,E,M]=float32_unpack(A);
    AA=float32_to_int(S,E,M);
    BB=int32(fix(AF));

    if((AA~=BB))
        fprintf('emulation: %d = single(%g)\n',AA,AF);
        fprintf('native:    %d = single(%g)\n',BB,AF);
        error(message('hdlcommon:nativefloatingpoint:NfpEmlAuthoredNumericMismatch','signed packed-to-single'));
    end
end

function fp32_check_op(A,B,C,CC,Z,ZZ,Op)
    if(Z~=ZZ)&&(~isnan(Z)||~isnan(ZZ))
        X=packed_to_single(A);
        Y=packed_to_single(B);
        fprintf('emulation: %g %s %g = %g  <->  0x%x %s 0x%x = 0x%x\n',X,Op,Y,Z,A,Op,B,C);
        fprintf('native:    %g %s %g = %g  <->  0x%x %s 0x%x = 0x%x\n',X,Op,Y,ZZ,A,Op,B,CC);
        fprintf('test_pair(%d,%d)\n',int32(A),int32(B));
        error(message('hdlcommon:nativefloatingpoint:NfpEmlAuthoredNumericMismatch',Op));
    end
end

function fp32_check_op_nrm(A,B,C,CC,Z,ZZ,Op)
    if~(float32_isdenorm(A)||float32_isdenorm(B))&&...
        ~(float32_isdenorm(C)&&float32_isdenorm(CC))&&...
        ~(float32_iszero(C)&&float32_isdenorm(CC))
        fp32_check_op(A,B,C,CC,Z,ZZ,Op);
    end
end

function b=float32_isdenorm(I)
    [~,E,~]=float32_unpack(I);
    b=(E==0);
end

function b=float32_iszero(I)
    b=(bitset(I,32,0)==0);
end
