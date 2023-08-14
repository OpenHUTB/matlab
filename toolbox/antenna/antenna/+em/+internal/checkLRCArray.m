function t=checkLRCArray(objExciter)




    if isa(objExciter,'linearArray')||isa(objExciter,'rectangularArray')...
        ||isa(objExciter,'circularArray')
        t=1;
    else
        t=0;
    end
