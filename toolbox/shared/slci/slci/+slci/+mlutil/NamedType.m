







classdef NamedType<handle

    properties

        fName;

        fType;
    end

    methods(Access=public)


        function aObj=NamedType(aName,aType)
            aObj.fName=aName;
            if nargin>1

                aObj.fType=aType;
            end
        end


        function name=getName(aObj)
            name=aObj.fName;
        end


        function type=getType(aObj)
            type=aObj.fType;
        end


        function flag=hasType(aObj)
            flag=~isempty(aObj.fType);
        end

    end

end
