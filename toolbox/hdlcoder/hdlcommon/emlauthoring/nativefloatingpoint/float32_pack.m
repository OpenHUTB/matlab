%#codegen
function P=float32_pack(Sign,Exp,Mant)


    coder.allowpcode('plain')

    P=uint32(bitor(bitshift(uint32(Sign),31),bitor(bitshift(uint32(Exp),23),uint32(Mant))));
end
