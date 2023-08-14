classdef(Hidden)ProjectData<handle






    properties
        Systems coder.internal.projectbuild.System=coder.internal.projectbuild.System.empty();
    end

    properties(GetAccess=private,SetAccess=immutable)
        Serializer coder.internal.projectbuild.ProjectSerializer;
    end

    methods
        function this=ProjectData(projectManager)

            this.Serializer=coder.internal.projectbuild.ProjectSerializer(this);

            if nargin>0
                this.load(projectManager);
            end
        end




        function system=getSystemData(this,systemName)
            system=this.Systems(strcmp(systemName,{this.Systems.Name}));
        end



        function[type,system]=getModelType(this,model)
            type=coder.internal.projectbuild.SystemModelType.None;
            system='';

            for i=1:length(this.Systems)
                type=this.Systems(i).getModelType(model);
                if type~=coder.internal.projectbuild.SystemModelType.None
                    system=this.Systems(i);
                    break;
                end
            end
        end



        function load(this,projectManager)

            this.Serializer.deserialize(projectManager);
        end



        function save(this,projectManager)

            this.Serializer.serialize(projectManager);
        end
    end
end


