%#codegen
function out=hdleml_counter_limit(count_limit,ic)


    coder.allowpcode('plain')
    eml_prefer_const(count_limit,ic);


    nt=numerictype(count_limit);
    fm=hdlfimath;
    zero=fi(0,nt,fm);
    one=fi(1,nt,fm);



    COUNT_MAX=fi(2^(nt.WordLength)-one,nt,fm);
    COMPLEMENT_VALUE=fi(COUNT_MAX-count_limit+one,nt,fm);
    NEXT2LAST_VALUE=fi(count_limit-one,nt,fm);
    STEP_VALUE=one;


    isCountToMax=count_limit==COUNT_MAX;

    doOptimize=count_limit>=8;
    eml_const(isCountToMax);

    persistent count;
    if isempty(count)
        count=eml_const(ic);
    end

    persistent stepreg
    if isempty(stepreg)
        stepreg=STEP_VALUE;
    end

    out=count;


    if~isCountToMax&&doOptimize

        count(:)=count+stepreg;

        if out==NEXT2LAST_VALUE
            stepreg=COMPLEMENT_VALUE;
        else
            stepreg=STEP_VALUE;
        end

    elseif~isCountToMax&&~doOptimize

        if count==count_limit
            count(:)=zero;
        else
            count(:)=count+STEP_VALUE;
        end

    else

        count(:)=count+STEP_VALUE;
    end


