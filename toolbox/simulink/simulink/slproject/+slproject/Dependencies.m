classdef Dependencies





    properties(Dependent,GetAccess=public,SetAccess=private)

Graph
    end

    properties(GetAccess=private,SetAccess=immutable)
Project
    end

    methods(Access=public,Hidden)
        function obj=Dependencies(project)
            obj.Project=project;
        end
    end

    methods

        function graph=get.Graph(obj)



















            graph=obj.Project.Dependencies;
        end

        function update(obj)












            obj.Project.updateDependencies();
        end

    end

end
