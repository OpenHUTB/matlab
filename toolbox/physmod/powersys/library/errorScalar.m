function errorScalar(parameter,name,block)





    if~isscalar(parameter)
        error(message('physmod:powersys:common:NonScalarParameter',name,block));
    end