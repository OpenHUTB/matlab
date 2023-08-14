%#codegen
function P=float64_pack(Sign,Exp,Mant)


    coder.allowpcode('plain')

    P=uint64(bitor(bitshift(uint64(Sign),63),bitor(bitshift(uint64(Exp),52),uint64(Mant))));
end
