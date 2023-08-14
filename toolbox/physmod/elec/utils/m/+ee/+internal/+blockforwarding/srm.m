function out=srm(in)










    out=in;


    if strcmp(in.getValue('stator_param'),'2')
        out=out.setValue('stator_param','3');
    end

end
