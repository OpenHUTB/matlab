%#codegen
function out=hdleml_counter_freerunning(outtpex,ic)


    coder.allowpcode('plain')
    eml_prefer_const(outtpex,ic);


    nt=numerictype(outtpex);
    fm=hdlfimath;
    one=fi(1,nt,fm);

    persistent count;
    if isempty(count)
        count=eml_const(ic);
    end

    out=count;

    if nt.WordLength==1

        count=bitcmp(count);
    else
        count=fi(count+one,nt,fm);
    end
