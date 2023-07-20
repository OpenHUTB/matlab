

classdef CodeGenFolderStructureConstraint<slci.compatibility.Constraint



    methods


        function obj=CodeGenFolderStructureConstraint()
            obj=obj@slci.compatibility.Constraint();
            obj.setEnum('CodeGenFolderStructure');
            obj.setCompileNeeded(0);
        end


        function out=getDescription(aObj)%#ok
            out='Target environment folder option is not supported';
        end


        function out=check(aObj)
            out=[];
            targetEnvFolder=false;
            obj=get_param(0,'CodeGenFolderStructure');
            if~strcmp(obj,'ModelSpecific')
                targetEnvFolder=true;
            end

            if targetEnvFolder
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'CodeGenFolderStructure',...
                aObj.ParentModel().getName());
                return
            end
        end
    end
end
