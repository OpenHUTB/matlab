function[tyo,tyoo]=realFloatingPointOnlyRule(errorMechanism,op,ty1,ty2,ty3)









    narginchk(4,5);


    try
        if nargin>4
            [tyo,tyoo]=feval('_gpu_realFloatingPointOnlyRule',op,ty1,ty2,ty3);
        else
            [tyo,tyoo]=feval('_gpu_realFloatingPointOnlyRule',op,ty1,ty2);
        end
    catch err
        encounteredError(errorMechanism,err);
    end
