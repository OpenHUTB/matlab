classdef SCMDataBuilder<handle



    properties(Access=private)
        TheirsSanitiser;
        BaseSanitiser;
        MineSanitiser;
        JSCMDataBuilder;
        ExternallyLaunched=false;
    end


    methods(Access=public)

        function obj=SCMDataBuilder()
            obj.JSCMDataBuilder=...
            javaObject('com.mathworks.comparisons.scm.ImmutableSourceControlMergeData$Builder');
        end

        function obj=addBaseFile(obj,baseFile)
            obj.BaseSanitiser=slxmlcomp.internal.link.ModelFileNameSanitiser(baseFile);
            obj.addSourceFile(obj.BaseSanitiser,'Base');
        end

        function obj=addMineFile(obj,mineFile)
            obj.MineSanitiser=slxmlcomp.internal.link.ModelFileNameSanitiser(mineFile);
            obj.addSourceFile(obj.MineSanitiser,'Mine');
        end

        function obj=addTheirsFile(obj,theirsFile)
            obj.TheirsSanitiser=slxmlcomp.internal.link.ModelFileNameSanitiser(theirsFile);
            obj.addSourceFile(obj.TheirsSanitiser,'Theirs');
        end

        function addTargetFile(obj,targetFile)
            obj.JSCMDataBuilder.setTargetFile(java.io.File(targetFile));
        end

        function setExternallyLaunched(obj,externallyLaunched)
            obj.ExternallyLaunched=externallyLaunched;
        end

        function jSCMData=build(obj)

            foldersToCleanup=getFoldersToCleanup(obj);

            jFolders=java.util.ArrayList();

            for folder=foldersToCleanup()
                jFolders.add(java.io.File(folder));
            end

            import com.mathworks.comparisons.merge.FolderCleanupAfterSCMMerge;
            import com.mathworks.comparisons.scm.CompoundPostMergeAction;
            import com.mathworks.comparisons.gui.hierarchical.merge.CloseMatlabAfterSCMMerge;

            folderCleanup=FolderCleanupAfterSCMMerge(jFolders);

            if obj.ExternallyLaunched
                closeMatlab=CloseMatlabAfterSCMMerge();
                postMergeAction=CompoundPostMergeAction(closeMatlab,folderCleanup);
            else
                postMergeAction=folderCleanup;
            end

            obj.JSCMDataBuilder.setPostMergeAction(postMergeAction);

            jSCMData=obj.JSCMDataBuilder.build();
        end

        function foldersToCleanup=getFoldersToCleanup(obj)
            foldersToCleanup={...
            obj.BaseSanitiser.TempDir,...
            obj.TheirsSanitiser.TempDir,...
            obj.MineSanitiser.TempDir...
            };
            emptyInds=cellfun(@isempty,foldersToCleanup);

            foldersToCleanup=foldersToCleanup(~emptyInds);

        end

    end


    methods(Access=private)

        function addSourceFile(obj,modelNameSanitiser,side)

            jSanitisedFile=java.io.File(modelNameSanitiser.SanitisedFilePath);

            feval(['set',side,'File'],obj.JSCMDataBuilder,jSanitisedFile);

            if~strcmp(modelNameSanitiser.SanitisedFilePath,modelNameSanitiser.OriginalFilePath)
                scmFileProperty=message('SimulinkXMLComparison:engine:SCMFileProperty');

                feval(['add',side,'FileProperty'],obj.JSCMDataBuilder,...
                scmFileProperty.getString(),...
                modelNameSanitiser.OriginalFilePath...
                );
            end

            [~,name,ext]=fileparts(modelNameSanitiser.OriginalFilePath);
            feval(['set',side,'Title'],obj.JSCMDataBuilder,[name,ext]);

        end

    end

end

