%#codegen

function c=e_single_multiply(a,b)
    coder.allowpcode('plain');
    coder.inline('never');

    [sign_a,exp_a,mant_a]=e_single_unpack(a);
    [sign_b,exp_b,mant_b]=e_single_unpack(b);

    if mant_a==0
        c=a;
    elseif mant_b==0
        c=b;
    else
        sign_c=bitxor(sign_a,sign_b);
        mant_c_48=mant_a*mant_b;

        e_add=cast(0,'like',exp_a);
        if bitget(mant_c_48,48)
            e_add(:)=1;
        else
            mant_c_48(:)=bitsll(mant_c_48,1);
        end

        mant_c_24=bitconcat(fi(0,0,1,0,hdlfimath),bitsliceget(mant_c_48,47,25));

        m_add=fi(0,0,1,0,hdlfimath);
        if bitget(mant_c_48,24)==1
            if bitget(mant_c_24,1)==1
                m_add(:)=1;
            elseif bitsliceget(mant_c_48,23,1)~=0
                m_add(:)=1;
            else
                m_add(:)=0;
            end
        end

        mant_c_24(:)=mant_c_24+m_add;
        if bitget(mant_c_24,24)==1
            e_add(:)=e_add+1;
        end

        mant_c=bitsliceget(mant_c_24,23,1);

        exp_c=exp_a+exp_b+e_add+cast(127,'like',exp_a);

        c=bitconcat(bitconcat(sign_c,exp_c),mant_c);
    end
end
