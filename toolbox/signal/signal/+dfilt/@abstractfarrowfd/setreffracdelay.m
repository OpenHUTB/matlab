function reffracdelay=setreffracdelay(this,reffracdelay)





    if~isdeployed
        if~license('checkout','Signal_Blocks')
            error(message('signal:dfilt:abstractfarrowfd:setreffracdelay:LicenseRequired'));
        end
    end

    validaterefcoeffs(this.filterquantizer,'Fracdelay',reffracdelay);


