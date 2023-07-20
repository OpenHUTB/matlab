%#codegen
function[E,M]=float32_round_nrm(EE,MM,TrOne,TrSuf)


    coder.allowpcode('plain')

    E=uint8(EE);

    M=uint32(MM);
    M=bitset(M,24,((E==0)&&bitget(M,24)));
    M=M+uint32(TrOne&&logical(bitget(M,1)||TrSuf));
    E=E+uint8(bitget(M,24));
    M=bitset(M,24,0);

end
