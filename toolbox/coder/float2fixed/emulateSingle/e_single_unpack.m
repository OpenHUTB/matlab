%#codegen

function[sign,exp,mant]=e_single_unpack(value)
    coder.inline('always');
    coder.allowpcode('plain');

    fm=hdlfimath;


    sign=bitsliceget(value,32,32);

    exp_fm=fimath(hdlfimath,'SumMode','SpecifyPrecision','SumWordLength',8,'SumFractionLength',0);
    exp_nt=numerictype(1,8,0);

    exp_val=bitsliceget(value,31,24);
    exp=reinterpretcast(fi(exp_val,0,8,0,exp_fm)-fi(127,0,8,0,exp_fm),exp_nt);

    if exp_val==0
        mant=fi(0,0,24,0,fm);
    else
        exp=reinterpretcast(fi(exp_val,0,8,0,exp_fm)-fi(127,0,8,0,exp_fm),exp_nt);

        mant_23=bitsliceget(value,23,1);


        mant=bitconcat(fi(1,0,1,0,fm),mant_23);
    end
    mant=reinterpretcast(mant,numerictype(0,24,23));
end
