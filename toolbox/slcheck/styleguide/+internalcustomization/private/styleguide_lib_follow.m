function status=styleguide_lib_follow(usage)



    switch(usage)
    case 'check'
        status='on';
    case 'fixit'
        status='off';
    otherwise
        status='off';
    end