classdef SettablePropertyError















    methods(Static=true)
        function createAndThrowAsCaller(propertyName,propertyInClass,methodName,methodInClass)
            useMethodId='MATLAB:project:api:ModifiableReadOnlyDependentProperty';

            useMethodString=getString(message(...
            useMethodId,...
            propertyName,...
            propertyInClass,...
            methodName,...
            methodInClass));

            baseException=MException(...
            useMethodId,...
useMethodString...
            );

            baseException.throwAsCaller();
        end
    end

end
