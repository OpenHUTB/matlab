function h=loadobj(s)




    if isstruct(s)
        h=Simulink.SoftwareTargetCC;
        h.Name='Concurrent Execution';
        h.setPropEnabled('Name',false);
    else
        assert(isa(s,'Simulink.SoftwareTargetCC'));
        h=s;
    end
