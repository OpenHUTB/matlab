


classdef Label<handle


    properties(GetAccess=public,SetAccess=private)

        CategoryName;
        Name;

    end

    methods(Access=public)


        function obj=Label(categoryName,labelName)

            checkArgument(categoryName,'char','categoryName');
            checkArgument(labelName,'char','labelName');

            obj.CategoryName=char(categoryName);
            obj.Name=char(labelName);

            warning(message('MATLAB:project:api:APIDeprecation',...
            'Simulink.ModelManagement.Project.Label'));
        end

    end

end


function checkArgument(argumentVariable,expectedType,argumentName)

    Simulink.ModelManagement.Project.checkArgument(argumentVariable,expectedType,argumentName);

end

