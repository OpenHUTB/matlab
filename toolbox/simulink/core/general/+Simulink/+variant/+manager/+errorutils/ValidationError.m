classdef(Sealed)ValidationError<handle






    methods
        function obj=ValidationError(varBlockPathInModel,pathFromRoot,excep)
            obj.PathInModel=Simulink.variant.utils.getRenderedNameFromName(varBlockPathInModel);
            obj.PathInHierarchy=Simulink.variant.utils.replaceNewLinesWithSpaces(pathFromRoot);
            obj.Exception=excep;
        end
    end

    properties
PathInModel
PathInHierarchy
Exception
    end

end
