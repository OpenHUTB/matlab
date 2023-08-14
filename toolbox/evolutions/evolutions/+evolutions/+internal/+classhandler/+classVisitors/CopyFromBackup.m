classdef CopyFromBackup<evolutions.internal.classhandler.classVisitors.Visitor




    methods(Access=?evolutions.internal.classhandler.classVisitors.Visitor)
        function visitBaseFileInfo(this,baseFileInfo)
            this.copyFromBackup(baseFileInfo.XmlFile);
        end

        function visitEvolutionInfo(this,evolutionInfo)
            this.copyFromBackup(evolutionInfo.XmlFile);
        end

        function visitEdge(this,edge)
            this.copyFromBackup(edge.XmlFile);
        end

        function visitEvolutionTreeInfo(this,evolutionTreeInfo)

            evolutions.internal.BackupReader.updateIds(evolutionTreeInfo);
            this.copyFromBackup(evolutionTreeInfo.XmlFile);


            evolutionTreeInfo.EvolutionManager.copyFromBackup;
            evolutionTreeInfo.EdgeManager.copyFromBackup;
        end
    end

    methods(Static=true,Access=protected)
        function copyFromBackup(filename)
            if isfile(filename)&&evolutions.internal.BackupReader.hasBackup(filename)
                backupFileName=evolutions.internal.BackupReader.getBackupFile(filename);
                try

                    copyfile(backupFileName,filename);
                catch ME

                    exception=MException...
                    ('evolutions:manage:BackupReadFail',getString(message...
                    ('evolutions:manage:BackupReadFail')));
                    exception=exception.addCause(ME);
                    throw(exception);
                end
            end
        end
    end
end


