classdef CppDataAccessInfo<handle





    methods(Static,Access='public')
        function validProperties=getAllowedProperties(category)
            if coder.mapping.internal.CppDataAccessInfo.isDataAccessValidForModelElementCategory(category)
                validProperties={'DataVisibility','MemberAccessMethod','DataAccess'};
            else
                validProperties={'DataVisibility','MemberAccessMethod'};
            end
        end
        function isValid=isDataAccessValidForModelElementCategory(category)
            isValid=isequal(category,'ModelParameterArguments')||(...
            (isequal(category,'Inports')||isequal(category,'Outports'))&&...
            matlab.internal.feature("CppExternalIOCustomization")>0);
        end
        function isValid=usesCppExternalIO(property)
            isValid=isequal(property,'DataAccess')&&matlab.internal.feature("CppExternalIOCustomization")>0;
        end
    end

end
