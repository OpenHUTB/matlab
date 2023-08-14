function disp(h)




    if length(h)==1
        disp(sprintf('[%s]',class(h)));
        disp(get(h));
    elseif length(h)<32
        for i=1:length(h)
            disp(sprintf('[%s]',class(h(i))));
        end
    else
        disp(h);
    end