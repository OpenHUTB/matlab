function out=rectifier(in)










    out=in;


    if str2double(in.getValue('model_dynamics'))==0
        out=out.setValue('model_dynamics','ee.enum.converters.diode.nodynamics');
    elseif str2double(in.getValue('model_dynamics'))==1
        out=out.setValue('model_dynamics','ee.enum.converters.diode.chargedynamics');
    end

end