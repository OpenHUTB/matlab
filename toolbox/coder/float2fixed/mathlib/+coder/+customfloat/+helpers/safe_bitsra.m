%#codegen



function mant_b_shifted=safe_bitsra(mant_b_ext,shift_length)
    coder.allowpcode('plain');

    if(shift_length>=mant_b_ext.WordLength)
        if(mant_b_ext<0)
            mant_b_shifted=cast(-1,'like',mant_b_ext);
        else
            mant_b_shifted=cast(0,'like',mant_b_ext);
        end
    else
        mant_b_shifted=bitsra(mant_b_ext,shift_length);
    end
end
