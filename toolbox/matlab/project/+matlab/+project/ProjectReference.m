classdef ProjectReference<matlab.project.FolderReference







    properties(Dependent=true,GetAccess=public,SetAccess=private)

        Project;

    end
    properties(GetAccess=private,SetAccess=private)
        Enabled=false;
    end


    methods(Access=public,Hidden=true)
        function obj=ProjectReference(varargin)

            obj=obj@matlab.project.FolderReference(varargin{:});

            if(nargin~=0&&numel(varargin{1})==0)
                obj=matlab.project.ProjectReference.empty(1,0);
                return;
            end

        end


        function obj=enable(obj)


            obj.Enabled=true;
        end

    end

    methods

        function proj=get.Project(obj)
            import matlab.internal.project.containers.ReferencedProjectContainer;
            proj=matlab.project.Project(...
            ReferencedProjectContainer(obj.File,obj.Enabled)...
            );
        end

    end

end
