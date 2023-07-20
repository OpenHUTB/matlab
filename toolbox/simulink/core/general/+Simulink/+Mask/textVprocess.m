

function valign=textVprocess(param)



    valign='';
    if(~isempty(regexp(param,'^(top|bottom|middle|cap|base)$','match')))
        valign=param;
    end
end