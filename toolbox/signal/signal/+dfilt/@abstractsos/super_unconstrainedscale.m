function super_unconstrainedscale(Hd,opts,L)





    if~isdeployed
        if~license('checkout','Signal_Blocks')
            error(message('signal:dfilt:abstractsos:super_unconstrainedscale:LicenseRequired'));
        end
    end


    unconstrainedscale(Hd,opts,L);


