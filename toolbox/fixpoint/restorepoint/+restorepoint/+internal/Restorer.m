classdef Restorer<handle




    properties(GetAccess=public,SetAccess=public)

RestoreDataStrategy
PreRestoreStrategy
RestoreStrategy
PostRestoreStrategy
    end

    methods
        function obj=Restorer(restoreDataStrategy,preRestoreStrategy,restoreStrategy,postRestoreStrategy)



            if nargin>0

                obj.RestoreDataStrategy=restoreDataStrategy;
                obj.PreRestoreStrategy=preRestoreStrategy;
                obj.RestoreStrategy=restoreStrategy;
                obj.PostRestoreStrategy=postRestoreStrategy;
            else
                obj.RestoreDataStrategy=restorepoint.internal.restore.RestorePointRestoreData;
                obj.PreRestoreStrategy=restorepoint.internal.restore.PreRestoreCloseModifiedElement;
                obj.RestoreStrategy=restorepoint.internal.restore.RestorePointRestoreStrategy;
                obj.PostRestoreStrategy=restorepoint.internal.restore.PostRestoreNoLoad;
            end
        end


        function set.RestoreDataStrategy(obj,restoreDataStrategy)
            validateattributes(restoreDataStrategy,...
            {'restorepoint.internal.restore.RestoreDataStrategy'},{'nonempty'});
            obj.RestoreDataStrategy=restoreDataStrategy;
        end

        function set.PreRestoreStrategy(obj,preRestoreStrategy)
            validateattributes(preRestoreStrategy,...
            {'restorepoint.internal.restore.PreRestoreStrategy'},{'nonempty'});
            obj.PreRestoreStrategy=preRestoreStrategy;
        end

        function set.RestoreStrategy(obj,restoreStrategy)
            validateattributes(restoreStrategy,...
            {'restorepoint.internal.restore.RestoreStrategy'},{'nonempty'});
            obj.RestoreStrategy=restoreStrategy;
        end

        function set.PostRestoreStrategy(obj,postRestoreStrategy)
            validateattributes(postRestoreStrategy,...
            {'restorepoint.internal.restore.PostRestoreStrategy'},{'nonempty'});
            obj.PostRestoreStrategy=postRestoreStrategy;
        end

        function restoreOutput=run(obj)
            allRestoreData=obj.RestoreDataStrategy.run;
            restoreOutput=obj.initializeRestoreOutput(allRestoreData);

            if(isempty(restoreOutput.FilesThatCannotBeRestored)&&isempty(restoreOutput.MissingDirectories))


                obj.PreRestoreStrategy.run(allRestoreData);
                obj.RestoreStrategy.run(allRestoreData);
                obj.PostRestoreStrategy.run(allRestoreData);
                restoreOutput.Status=true;
            end
        end
    end

    methods(Static=true,Access=private)
        function restoreOutput=initializeRestoreOutput(allRestoreData)
            restoreOutput=restorepoint.internal.restore.RestoreOutput;
            restoreOutput.FilesToRestore=allRestoreData.FilesToRestore;
            restoreOutput.FilesThatCannotBeRestored=allRestoreData.FilesThatCannotBeRestored;
            restoreOutput.MissingDirectories=...
            restorepoint.internal.utils.findMissingDirectories(allRestoreData.FilesToRestore);
            [restoreOutput.WriteProtectedFiles,restoreOutput.WriteProtectedDir]=...
            restorepoint.internal.utils.checkFilePermissions(allRestoreData.FilesThatCannotBeRestored);
        end
    end
end




