

















classdef tempdirManager<handle

    methods(Static,Access=public)

        function tempDir=createTempDir()

            import com.mathworks.toolbox.rptgenxmlcomp.comparison.*;
            try
                tempDir=XMLComparisonTempDirManager.createTempDir();
                tempDir=char(tempDir.getAbsolutePath());
            catch E
                xmlcomp.internal.error('engine:cannotCreateTempFiles',E.message);
            end
        end

        function deleteAllTempDirs()


            import com.mathworks.toolbox.rptgenxmlcomp.comparison.*;
            success=XMLComparisonTempDirManager.deleteContentsOfRootDir();
            if~success
                xmlcomp.internal.tempdirManager.throwDeleteTempFilesWarning();
            end
        end

        function deleteAllFailureTempDirs()

            import com.mathworks.toolbox.rptgenxmlcomp.comparison.*;
            success=XMLComparisonTempDirManager.deleteContentsOfFailuresRootDir();
            if~success
                xmlcomp.internal.tempdirManager.throwDeleteTempFilesWarning();
            end
        end

        function deleteRootDir()



        end

        function folders=getAllTempFolders()

            import com.mathworks.toolbox.rptgenxmlcomp.comparison.*;
            tempFolders=XMLComparisonTempDirManager.getAllTempDirs();
            folders={};
            iterator=tempFolders.iterator();
            while iterator.hasNext()
                folder=iterator.next();
                folders={folders{:},char(folder.getAbsolutePath())};%#ok<CCAT>
            end
        end

        function latest=getCurrentTempdir()

            import com.mathworks.toolbox.rptgenxmlcomp.comparison.*;
            latest=[];
            latestDir=XMLComparisonTempDirManager.getLatestTempDir();
            if~isempty(latestDir)
                latest=char(latestDir.getAbsolutePath());
            end
        end

        function root=getTempdirRoot()

            import com.mathworks.toolbox.rptgenxmlcomp.comparison.*;
            try
                root=char(XMLComparisonTempDirManager.getRootDir().getAbsolutePath());
            catch E
                xmlcomp.internal.error('engine:cannotCreateTempFiles',E.message);
            end
        end

        function root=getFailuresTempdirRoot()

            import com.mathworks.toolbox.rptgenxmlcomp.comparison.*;
            try
                root=char(XMLComparisonTempDirManager.getFailuresRootDir().getAbsolutePath());
            catch E
                xmlcomp.internal.error('engine:cannotCreateTempFiles',E.message);
            end
        end

        function cd()

            tmpDir=xmlcomp.internal.tempdirManager.getCurrentTempdir();
            if~isempty(tmpDir)
                cd(tmpDir)
            end
        end

    end


    methods(Static,Access=private)

        function throwDeleteTempFilesWarning()
            key='engine:DeleteTempFilesFailed';
            message=xmlcomp.internal.message(key);
            warning(['XMLComparison:',key],'%s',message);
        end

    end

end
