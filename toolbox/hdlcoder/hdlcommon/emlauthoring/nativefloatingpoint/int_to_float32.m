%#codegen
function[S,E,M]=int_to_float32(x)


    coder.allowpcode('plain')

    if(x<0)
        [~,E,M]=uint_to_float32(uint32(-x));
        S=1;
    else
        [S,E,M]=uint_to_float32(uint32(x));
    end

end
