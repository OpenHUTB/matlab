function[type,obj]=getObjectiveType(obj)










%#codegen

    coder.allowpcode('plain');


    coder.inline('always');

    type=obj.objtype;
end

