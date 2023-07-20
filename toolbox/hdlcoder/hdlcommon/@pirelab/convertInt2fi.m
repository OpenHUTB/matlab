
function y=convertInt2fi(u)






    if isfloat(u)
        y=u;
    elseif islogical(u)
        y=fi(u,0,1,0,hdlfimath);
    else
        y=fi(u,hdlfimath);
    end
