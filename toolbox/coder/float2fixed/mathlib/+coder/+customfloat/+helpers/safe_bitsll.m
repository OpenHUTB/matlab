%#codegen




function mant_a=safe_bitsll(mant_a,shift_length)
    coder.allowpcode('plain');

    if shift_length>=mant_a.WordLength
        mant_a(:)=0;
    else
        mant_a(:)=bitsll(mant_a,shift_length);
    end
end

