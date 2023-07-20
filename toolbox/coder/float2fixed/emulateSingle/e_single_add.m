%#codegen

function c=e_single_add(a,b)
    coder.allowpcode('plain');
    coder.inline('never');

    [sign_a,exp_a,mant_a]=e_single_unpack(a);
    [sign_b,exp_b,mant_b]=e_single_unpack(b);

    if mant_a==0
        c=b;
    elseif mant_b==0
        c=a;
    else
        exp_bias=cast(127,'like',exp_a);
        if exp_a>=exp_b
            c=flt_add_impl(sign_a,sign_b,exp_a,exp_b,exp_bias,mant_a,mant_b);
        else
            c=flt_add_impl(sign_b,sign_a,exp_b,exp_a,exp_bias,mant_b,mant_a);
        end
    end
end

function c_out=flt_add_impl(sign_a,sign_b,exp_a,exp_b,exp_bias,mant_a,mant_b)
    coder.inline('always');

    ML=mant_a.WordLength;
    FULL_ML=ML*2+1;

    diff=exp_a-exp_b;

    mant_a=bitconcat(mant_a,fi(0,0,ML,0,hdlfimath));
    mant_b=bitconcat(mant_b,fi(0,0,ML,0,hdlfimath));

    if diff>ML
        mant_b(:)=0;
    elseif diff>0
        mant_b=bitsrl(mant_b,diff);
    elseif diff<0
        mant_b(:)=0;
    end

    exp_c=exp_a+cast(exp_bias,'like',exp_a);
    mant_a=reinterpretcast(bitconcat(fi(0,0,1,0),mant_a),numerictype(1,FULL_ML,0));
    mant_b=reinterpretcast(bitconcat(fi(0,0,1,0),mant_b),numerictype(1,FULL_ML,0));

    if sign_a
        mant_a(:)=-mant_a;
    end
    if sign_b
        mant_b(:)=-mant_b;
    end


    mant_c_full=mant_a+mant_b;
    sign_c=bitget(mant_c_full,FULL_ML+1);
    if sign_c
        mant_c_full(:)=-mant_c_full;
    end

    mant_c_full=reinterpretcast(mant_c_full,numerictype(0,mant_c_full.WordLength,mant_c_full.FractionLength));
    if mant_c_full==0
        c=fi(0,0,1+exp_a.WordLength+ML-1,0,hdlfimath);
    else
        if bitget(mant_c_full,FULL_ML)==1
            exp_c(:)=exp_c+1;
        else
            mant_c_full(:)=bitsll(mant_c_full,1);
            [mant_c_full,~,shifts]=normalize_fi(mant_c_full);
            mant_c_full=bitsrl(mant_c_full,1);
            exp_c(:)=exp_c-shifts+1;
        end

        mant_c_tmp=fi(bitconcat(fi(0,0,1,0,hdlfimath),bitsliceget(mant_c_full,FULL_ML-1,FULL_ML-ML+1)),hdlfimath);

        add=fi(0,0,1,0);
        if bitget(mant_c_full,FULL_ML-ML)==1
            if bitsliceget(mant_c_tmp,1)==1
                add(:)=1;
            elseif bitsliceget(mant_c_full,FULL_ML-ML-1,1)~=0
                add(:)=1;
            else
                add(:)=0;
            end
            mant_c_tmp(:)=fi(mant_c_tmp+add,hdlfimath);
        end
        mant_c=bitsliceget(mant_c_tmp,ML-1,1);
        if bitget(mant_c_tmp,ML)==1
            exp_c(:)=exp_c+1;
        end

        c=bitconcat(bitconcat(sign_c,exp_c),mant_c);
        c=fi(c,hdlfimath);
    end
    c_out=c;
end
