function Y=packed_to_single(I)
%#codegen


    coder.allowpcode('plain')

    Y=typecast(uint32(I),'single');
end
