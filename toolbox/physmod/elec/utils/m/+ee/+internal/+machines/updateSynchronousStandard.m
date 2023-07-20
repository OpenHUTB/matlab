function s=updateSynchronousStandard(s)%#codegen





    coder.allowpcode('plain');


    s.Xad=s.Xd-s.Xl;
    s.Xaq=s.Xq-s.Xl;


    if s.saturation_option==1
        s.saturation=ee.internal.machines.convertSynchronousSaturation(s.saturation.original.ifd,s.saturation.original.Vag,s.Xad,10);
    end

end