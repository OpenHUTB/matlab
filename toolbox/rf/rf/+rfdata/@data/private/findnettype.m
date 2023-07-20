function a_type=findnettype(h,a_string,default_type)




    if nargin<3
        default_type='';
    end
    if strcmpi(a_string,'S')
        a_type='S_PARAMETERS';
    elseif strcmpi(a_string,'Y')
        a_type='Y_PARAMETERS';
    elseif strcmpi(a_string,'Z')
        a_type='Z_PARAMETERS';
    elseif strcmpi(a_string,'H')
        a_type='H_PARAMETERS';
    elseif strcmpi(a_string,'G')
        a_type='G_PARAMETERS';
    else
        a_type=default_type;
    end
