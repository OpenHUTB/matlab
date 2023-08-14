%#codegen
function[outenb,preenb]=hdleml_cascade_controller2(in_vld,count_limit,mode_pre_in)



    coder.allowpcode('plain')
    eml_prefer_const(count_limit,mode_pre_in);

    if nargin<3
        mode_pre_in=false;
    end


    nt_cnt=numerictype(count_limit);
    fm=hdlfimath;


    zero_cnt=fi(0,nt_cnt,fm);
    one_cnt=fi(1,nt_cnt,fm);

    zero=fi(0,0,1,0,fm);
    one=fi(1,0,1,0,fm);

    persistent cnt;
    if isempty(cnt)
        cnt=zero_cnt;
    end

    if in_vld==one
        cnt=zero_cnt;
    elseif cnt==count_limit
        cnt=cnt;
    else
        cnt=fi(cnt+one_cnt,nt_cnt,fm);
    end


    if cnt==count_limit
        outenb=zero;
    else
        outenb=one;
    end




    if mode_pre_in
        pre_limit=fi(count_limit-one_cnt,nt_cnt,fm);
        if cnt==pre_limit
            preenb=one;
        else
            preenb=zero;
        end
    else
        preenb=zero;
    end

