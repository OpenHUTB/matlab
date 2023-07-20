function[y,errid,errargs]=integerToFi(x,fiObj)








    errid='';
    errargs={};



    if isinteger(x)
        y=cast([],'like',fi(x));
    else

        errid='fixed:fi:divideUnhandledIntegerType';
    end


    if~isempty(errid)

        y=[];
    else


        if isfimathlocal(fiObj)
            y=setfimath(y,fimath(fiObj));
        end
    end

end




