function[pexciter,texciter]=getExciterMesh(obj)


    [pexciter,texciter]=getMesh(obj.Exciter);

    translateVector=[0,0,-(-obj.Spacing)];
    pexciter=em.internal.translateshape(pexciter,translateVector);