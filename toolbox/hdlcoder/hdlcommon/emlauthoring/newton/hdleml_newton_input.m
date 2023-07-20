%#codegen
function[aout,dynamicShift]=hdleml_newton_input(ain,...
    reintp_ex,norm_ex,normWL,numOR,shiftv_ex)





    coder.allowpcode('plain')
    eml_prefer_const(reintp_ex,norm_ex,normWL,numOR,shiftv_ex);

    fm=hdlfimath;


    areintp=reinterpretcast(ain,numerictype(reintp_ex));
    anorm=fi(areintp,numerictype(norm_ex),fm);



    zero=fi(0,0,1,0,fm);
    aor=hdleml_define_len(zero,numOR);
    for ii=coder.unroll(1:numOR)
        lidx=normWL-(ii-1)*2;
        ridx=normWL-(ii-1)*2-1;
        aor(ii)=bitorreduce(bitsliceget(anorm,lidx,ridx));
    end



    dynamicShift=construct_switch_logics(aor,numOR,shiftv_ex);




    shiftnum=bitsll(dynamicShift,1);
    aout=bitsll(anorm,int(shiftnum));

end


function sel=construct_switch_logics(aor,numOR,shiftv_ex)

    eml_prefer_const(numOR);

    fm=hdlfimath;

    for ii=coder.unroll(1:numOR)
        if aor(ii)==fi(1,0,1,0,fm)
            sel=fi(ii-1,numerictype(shiftv_ex),fm);
            return;
        end
    end
    sel=fi(numOR,numerictype(shiftv_ex),fm);
end


