function checkConductorOnObjects(obj1,obj2)

    cond1=obj1.Conductor.Conductivity;
    cond2=obj2.Conductor.Conductivity;
    t1=obj1.Conductor.Thickness;
    t2=obj2.Conductor.Thickness;
    if~isequal(cond1,cond2)||~isequal(t1,t2)
        error(message('rfpcb:rfpcberrors:DifferingConductors'));
    end