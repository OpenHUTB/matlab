



classdef VASUtils

    methods(Static,Access='public')











        function modifiedName=getAllowedName(name)
            modifiedName=name;
            if isvarname(modifiedName)
                return;
            end
            expressionToReplace={'\W','_+','_$'};
            replaceWith={'_','_',''};
            for i=1:numel(expressionToReplace)
                modifiedName=regexprep(modifiedName,...
                expressionToReplace{i},replaceWith{i},'emptymatch');
            end
            if isempty(regexpi(modifiedName,'^[a-z]','match'))
                modifiedName=['s',modifiedName];
            end
        end









        function success=displayQuestDialogIfFolderNotOnPath(absFolderPath)


            success=1;
            allPaths=[strsplit(path,pathsep),{pwd}];
            if ismember(absFolderPath,allPaths)
                return;
            end

            questDlgMsg=DAStudio.message('Simulink:VariantBlockPrompts:VASAddPathQuestDlgMsg',absFolderPath);
            questDlgTitle=DAStudio.message('Simulink:VariantBlockPrompts:VASAddPathQuestDlgTitle');
            addPathMsg=DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathAddCurrentSession');
            doNotAddPathMsg=DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathDoNotAdd');
            cancelMsg=DAStudio.message('Simulink:modelReference:selectedMdlNotOnPathCancel');

            choice=questdlg(questDlgMsg,questDlgTitle,addPathMsg,doNotAddPathMsg,cancelMsg,cancelMsg);

            if strcmp(choice,cancelMsg)||isempty(choice)

                success=0;
                return;
            end

            if strcmp(choice,addPathMsg)

                addpath(absFolderPath)
            end
        end








        function absPathToSelectedFolder=browseFolder(startFolder,dialogTitle)

            assert(slfeature('VariantAssemblySubsystem')==1);

            absPathToSelectedFolder=uigetdir(startFolder,dialogTitle);

            if~absPathToSelectedFolder
                absPathToSelectedFolder='';
                return;
            end

            success=Simulink.variant.vas.VASUtils.displayQuestDialogIfFolderNotOnPath(absPathToSelectedFolder);

            if~success
                absPathToSelectedFolder='';
            end
        end


    end

end


