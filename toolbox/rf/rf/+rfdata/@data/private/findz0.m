function z0=findz0(h,aline)




    aline=strtrim(aline);
    if(numel(aline)>1)&&(strcmp('=',aline(1)))
        aline=aline(2:end);
    end
    aline=strtrim(aline);

    if(numel(aline)>1)&&(~isempty(strfind('+-',aline(1))))
        first_char=aline(1);
        templine=aline(2:end);
    else
        first_char='';
        templine=aline;
    end
    templine=strrep(templine,'I','');
    templine=strrep(templine,'J','');
    [token_plus,rem_plus]=strtok(templine,'+');
    [token_minus,rem_minus]=strtok(templine,'-');
    if~isempty(rem_plus)
        z0=str2num([first_char,token_plus])+...
        j*str2num(rem_plus);
    elseif~isempty(rem_minus)
        z0=str2num([first_char,token_minus])+...
        j*str2num(rem_minus);
    elseif~isempty(strfind(aline,'I'))||~isempty(strfind(aline,'J'))
        temp=strrep(aline,'I','');
        temp=strrep(temp,'J','');
        z0=j*str2num(temp);
    else
        z0=str2num(aline);
    end