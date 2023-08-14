function f=updateSynchronousFundamental(f)%#codegen





    coder.allowpcode('plain');


    f.Ld=f.Lad+f.Ll;
    f.Lq=f.Laq+f.Ll;


    f.Lffd=f.Lad+f.Lfd;
    f.L11d=f.Lad+f.L1d;
    f.L11q=f.Laq+f.L1q;

    switch f.num_q_dampers
    case 1

        f.L22q=nan;
    case 2

        f.L22q=f.L2q+f.Laq;
    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:machines:updateSynchronousFundamental:error_NumberOfQaxisDamperCircuits')),'1','2');
    end


    if f.saturation_option==1
        f.saturation=ee.internal.machines.convertSynchronousSaturation(f.saturation.original.ifd,f.saturation.original.Vag,f.Lad,10);
    end

end