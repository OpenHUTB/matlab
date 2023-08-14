function test_double_pair(A,B)



    AF=packed_to_double(A);
    BF=packed_to_double(B);
    [AS,AE,AM]=float64_unpack(A);
    [BS,BE,BM]=float64_unpack(B);

    [S,E,M]=float64_add(AS,AE,AM,BS,BE,BM);
    C=float64_pack(S,E,M);
    F=packed_to_double(C);
    CF=AF+BF;

    if(CF~=F)&&(~isnan(CF)||~isnan(F))
        fprintf('emulation: %g + %g = %g  <->  0x%x + 0x%x = 0x%x\n',AF,BF,F,A,B,C);
        fprintf('native:    %g + %g = %g  <->  0x%x + 0x%x = 0x%x\n',AF,BF,CF,A,B,double_to_packed(CF));
        fprintf('test_pair(uint64(%d),uint64(%d))\n',uint64(A),uint64(B));
        error('Failed!')
    end

    [S,E,M]=float64_add(AS,AE,AM,~BS,BE,BM);
    C=float64_pack(S,E,M);
    F=packed_to_double(C);
    CF=AF-BF;

    if(CF~=F)&&(~isnan(CF)||~isnan(F))
        fprintf('emulation: %g - %g = %g  <->  0x%x - 0x%x = 0x%x\n',AF,BF,F,A,B,C);
        fprintf('native:    %g - %g = %g  <->  0x%x - 0x%x = 0x%x\n',AF,BF,CF,A,B,double_to_packed(CF));
        fprintf('test_pair(uint64(%d),uint64(%d))\n',uint64(A),uint64(B));
        error('Failed!')
    end

    [S,E,M]=float64_mul(AS,AE,AM,BS,BE,BM);
    C=float64_pack(S,E,M);
    F=packed_to_double(C);
    CF=AF*BF;

    if(CF~=F)&&(~isnan(CF)||~isnan(F))
        fprintf('emulation: %g * %g = %g  <->  0x%x * 0x%x = 0x%x\n',AF,BF,F,A,B,C);
        fprintf('native:    %g * %g = %g  <->  0x%x * 0x%x = 0x%x\n',AF,BF,CF,A,B,double_to_packed(CF));
        fprintf('test_pair(uint64(%d),uint64(%d))\n',uint64(A),uint64(B));
        error('Failed!')
    end




















































































