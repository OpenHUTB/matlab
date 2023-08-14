function obj=restoreFromPhaseOne(obj)












%#codegen

    coder.allowpcode('plain');


    obj.objtype=obj.prev_objtype;
    obj.nvar=obj.prev_nvar;
    obj.hasLinear=obj.prev_hasLinear;

end

