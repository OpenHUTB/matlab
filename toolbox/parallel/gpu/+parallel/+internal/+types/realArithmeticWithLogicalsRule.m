function[tyo,tyoo]=realArithmeticWithLogicalsRule(errorMechanism,op,ty1,ty2)









    narginchk(4,4);


    try
        [tyo,tyoo]=feval('_gpu_realArithmeticWithLogicalsRule',op,ty1,ty2);
    catch err
        encounteredError(errorMechanism,err);
    end
