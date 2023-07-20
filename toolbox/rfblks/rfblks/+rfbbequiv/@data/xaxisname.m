function xname=xaxisname(h,parameter)








    xname='';


    dtype=category(h,parameter);


    switch dtype
    case{'Network Parameters','Noise Parameters','Phase Noise'}
        xname='Freq';
    case 'Power Parameters'
        xname='Pin';
    case 'AMAM/AMPM Parameters'
        xname='AM of Input';
    end
