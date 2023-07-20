classdef MemberInfo





    properties(Access=private)


mName


mValue

    end

    methods
        function obj=MemberInfo(name,value,unit)


            narginchk(3,3);


            validate_type(name,'char','name');


            obj.mName=name;
            obj.mValue=simscape.Value(value,unit);
        end

        function n=name(obj)
            n=obj.mName;
        end

        function v=value(obj)
            u=obj.mValue.unit;
            v=obj.mValue.value(u);
        end

        function u=unit(obj)
            u=obj.mValue.unit;
        end
    end
end

function validate_type(v,expType,errStr)
    if~strcmpi(class(v),expType)
        pm_error('physmod:simscape:simscape:smt:WrongInfoType',errStr,expType);
    end
end
