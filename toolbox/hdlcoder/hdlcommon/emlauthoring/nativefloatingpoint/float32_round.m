%#codegen
function[E,M]=float32_round(EE,MM,TrOne,TrSuf)


    coder.allowpcode('plain')

    E=uint8(EE);

    if(EE==255)
        M=uint32(0);
    else
        M=uint32(MM);
        M=bitset(M,24,((E==0)&&bitget(M,24)));
        M=M+uint32(TrOne&&(bitget(M,1)||TrSuf));
        E=E+uint8(bitget(M,24));
        M=bitset(M,24,0);
    end

end
