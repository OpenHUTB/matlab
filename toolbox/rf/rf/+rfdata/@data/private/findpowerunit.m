function a_unit=findpowerunit(h,a_string,default_unit)




    if nargin<3
        default_unit='';
    end
    if~isempty(strfind(a_string,'DBM'))
        a_unit='DBM';
    elseif~isempty(strfind(a_string,'DBW'))
        a_unit='DBW';
    elseif~isempty(strfind(a_string,'MW'))
        a_unit='MW';
    elseif~isempty(strfind(a_string,'W'))
        a_unit='W';
    else
        a_unit=default_unit;
    end