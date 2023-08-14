function a_scale=findfrequnit(h,a_string,default_scale)




    if(nargin<3)
        default_scale=[];
    end
    if~isempty(strfind(a_string,'GHZ'))
        a_scale=1e9;
    elseif~isempty(strfind(a_string,'MHZ'))
        a_scale=1e6;
    elseif~isempty(strfind(a_string,'KHZ'))
        a_scale=1e3;
    elseif~isempty(strfind(a_string,'HZ'))
        a_scale=1;
    else
        a_scale=default_scale;
    end