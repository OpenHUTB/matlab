function checkSubstratesOnObjects(obj1,obj2)

    epsr1=obj1.Substrate.EpsilonR;
    epsr2=obj2.Substrate.EpsilonR;
    lt1=obj1.Substrate.LossTangent;
    lt2=obj2.Substrate.LossTangent;
    t1=obj1.Substrate.Thickness;
    t2=obj2.Substrate.Thickness;
    if~isequal(epsr1,epsr2)||~isequal(lt1,lt2)||~isequal(t1,t2)
        error(message('rfpcb:rfpcberrors:DifferingSubstrates'));
    end