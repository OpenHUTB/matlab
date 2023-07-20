function a_format=findnetformat(h,a_string,default_format)




    if(nargin<3)
        default_format='';
    end
    if~isempty(strfind(a_string,'RI'))
        a_format='RI';
    elseif~isempty(strfind(a_string,'MA'))...
        ||~isempty(strfind(a_string,'MP'))
        a_format='MA';
    elseif~isempty(strfind(a_string,'DB'))
        if~isempty(strfind(a_string,'VDB'))
            a_format='VDB';
        else
            a_format='DB';
        end
    else
        a_format=default_format;
    end