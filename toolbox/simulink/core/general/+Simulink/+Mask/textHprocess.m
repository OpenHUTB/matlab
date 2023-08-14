

function halign=textHprocess(param)



    halign='';
    if(strcmpi(param,'left'))
        halign='start';
    else
        if(strcmpi(param,'right'))
            halign='end';
        else
            if(strcmpi(param,'center'))
                halign='middle';
            end
        end
    end
end