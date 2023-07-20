classdef FileDependencyWithSave<restorepoint.internal.create.FileDependencyStrategy











    properties(GetAccess=public,SetAccess=public)
FileDependencyStrategy
    end

    methods
        function obj=FileDependencyWithSave(fileDependencyStrategy)



            if nargin>0
                obj.FileDependencyStrategy=fileDependencyStrategy;
            else
                obj.FileDependencyStrategy=restorepoint.internal.create.FileDependencyStandard;
            end
        end

        function set.FileDependencyStrategy(obj,fileDependencyStrategy)
            assert(isa(fileDependencyStrategy,'restorepoint.internal.create.FileDependencyStrategy'));
            obj.FileDependencyStrategy=fileDependencyStrategy;
        end

        function run(obj,restoreData)
            obj.FileDependencyStrategy.run(restoreData);
            while~isempty(restoreData.OriginalDirtyFiles)
                obj.saveDirtyElements(restoreData.OriginalDirtyFiles);
                obj.FileDependencyStrategy.run(restoreData);
            end
        end
    end

    methods(Static,Access=private)
        function saveDirtyElements(dirtyElements)
            fileTypeHandler=restorepoint.internal.FileTypeHandler;

            for elementIdx=1:length(dirtyElements)
                currentFullFile=dirtyElements{elementIdx};

                fileData=struct('CurrentFullFile',currentFullFile);
                fileTypeHandler.saveDirtyFile(fileData);
            end
        end
    end

end


