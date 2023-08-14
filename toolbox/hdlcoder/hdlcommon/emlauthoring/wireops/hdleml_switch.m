%#codegen
function y=hdleml_switch(in1,sel,in2,threshold,op)


    coder.allowpcode('plain')
    eml_prefer_const(threshold,op);

    if~islogical(in1)
        u=fi(in1,numerictype(threshold),fimath(threshold));
    else
        u=in1;
    end

    if~islogical(in2)
        v=fi(in2,numerictype(threshold),fimath(threshold));
    else
        v=in2;
    end

    if~islogical(sel)
        s=fi(sel,numerictype(threshold),fimath(threshold));
        th=threshold;
    else
        s=sel;
        th=logical(threshold);
    end


    switch op
    case 1
        if(s>=th)
            y=u;
        else
            y=v;
        end
    case 2
        if(s>th)
            y=u;
        else
            y=v;
        end
    case 3
        if(s~=th)
            y=u;
        else
            y=v;
        end
    case 4
        if(s==th)
            y=u;
        else
            y=v;
        end
    otherwise

        y=0;
    end
