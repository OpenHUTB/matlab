%#codegen
function out=hdleml_counter_load(load,load_value)


    coder.allowpcode('plain')
    eml_prefer_const(load_value);



    nt=numerictype(load_value);
    fm=hdlfimath;

    zero=fi(0,nt,fm);
    one=fi(1,nt,fm);

    nt_load=numerictype(load);
    one_load=fi(1,nt_load,hdlfimath);

    persistent count;
    if isempty(count)
        count=zero;
    end
    out=count;

    count=fi(count+one,nt,fm);

    if load==one_load
        count=load_value;
    end




