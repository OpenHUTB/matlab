classdef(Abstract)Heterogeneous<matlab.mixin.Heterogeneous&handle





    properties(GetAccess=private,SetAccess=immutable)
        ObjectUuid char
    end

    methods
        function this=Heterogeneous()
            this.ObjectUuid=matlab.lang.internal.uuid();
        end
    end

    methods(Sealed)

        function equal=eq(a,b)
            [operatable,equal]=coderapp.internal.util.binaryOperatorHelper(a,b,...
            'coderapp.internal.util.Heterogeneous',Placeholder=false,DebugName='EQ');
            if operatable
                equal=reshape(strcmp({a.ObjectUuid},{b.ObjectUuid}),size(equal));
            end
        end


        function notEqual=ne(a,b)
            notEqual=~eq(a,b);
        end


        function hash=keyHash(obj)
            hash=keyHash(obj.ObjectUuid);
        end


        function tf=keyMatch(obj1,obj2)
            tf=strcmp(class(obj1),class(obj2))&&obj1==obj2;
        end
    end
end