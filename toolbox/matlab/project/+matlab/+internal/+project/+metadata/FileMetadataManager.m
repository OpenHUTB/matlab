classdef FileMetadataManager








    properties(GetAccess=private,SetAccess=private,Hidden=true)
Delegate
    end

    methods(Access=public,Hidden=true)
        function obj=FileMetadataManager(project,applicationName)
            if matlab.internal.project.util.useWebFrontEnd
                if isa(project,"slproject.ProjectManager")
                    obj.Delegate=matlab.internal.project.api.FileMetadataManager(project.Project,applicationName);
                    return
                end
                obj.Delegate=matlab.internal.project.api.FileMetadataManager(project,applicationName);
            else
                obj.Delegate=matlab.internal.project.metadata.FileMetadataManagerJava(project,applicationName);
            end
        end
    end

    methods(Access=public)
        function node=getMetadata(obj,file)
            import matlab.internal.project.metadata.FileMetadataNode;
            file=obj.handleSlProjectFile(file);
            node=FileMetadataNode(obj.Delegate.getMetadata(file));
        end

        function setMetadata(obj,file,node)
            file=obj.handleSlProjectFile(file);
            obj.Delegate.setMetadata(file,node.Delegate);
        end

        function setAllMetadata(obj,allData)
            obj.Delegate.setAllMetadata(allData.Delegate);
        end

        function removeEntry(obj,file)
            file=obj.handleSlProjectFile(file);
            obj.Delegate.removeEntry(file);
        end

        function allData=getAllMetadata(obj)
            import matlab.internal.project.metadata.FileNodeMap;
            allData=FileNodeMap(obj.Delegate.getAllMetadata());
        end
    end

    methods(Access=private)
        function outFile=handleSlProjectFile(~,inFile)
            if isa(inFile,"slproject.ProjectFile")
                outFile=inFile.Path;
                return
            end
            outFile=inFile;
        end
    end
end
