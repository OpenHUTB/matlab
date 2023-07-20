function cs=convertToCell(in)






















    if isempty(in)
        if ischar(in)
            cs={''};
        else
            cs={};
        end
        return;
    end


    cs=in;
    if~iscell(in)
        cs={in};
    end


    [m,n]=size(cs);

    if(n>m)
        cs=cs';
    end
