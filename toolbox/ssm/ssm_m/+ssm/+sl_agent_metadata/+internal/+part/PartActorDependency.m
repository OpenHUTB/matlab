classdef PartActorDependency<ssm.sl_agent_metadata.internal.part.Part




    properties
        ModelName(1,:)char=''
        DependencyList(1,:)cell
        DataFileList(1,:)string
    end

    methods
        function obj=PartActorDependency()
            obj@ssm.sl_agent_metadata.internal.part.Part('modelfiles')
        end

        function populateFileList(obj)


            if isempty(obj.ModelName);return;end


            for idx=1:numel(obj.DependencyList)
                obj.addPartUsingFilePattern(obj.DependencyList{idx},obj.ModelName);
            end


            for idx=1:numel(obj.DataFileList)
                obj.addPartUsingFilePattern(obj.DataFileList{idx},obj.ModelName);
            end


            fullfileStr=string({obj.FileList.SrcFolder})+filesep+string({obj.FileList.FileName});
            [~,ia,~]=unique(fullfileStr,'stable');
            obj.FileList=obj.FileList(ia);
        end

        function populateInformation(~)

        end

    end
end


