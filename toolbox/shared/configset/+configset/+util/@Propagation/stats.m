function out=stats(h)

    vs=h.Map.values;
    c=0;
    r=0;
    s=0;
    f=0;
    for i=1:h.Number
        v=vs{i};

        switch v.Status
        case 'Converted'
            c=c+1;
        case 'Restored'
            r=r+1;
        case 'Skipped'
            s=s+1;
        case 'Failed'
            f=f+1;
        end

        if v.Fail
            f=f+1;
        end
    end

    a.t=h.Number;
    a.c=c;
    a.r=r;
    a.s=s;
    a.f=f;

    out=a;
