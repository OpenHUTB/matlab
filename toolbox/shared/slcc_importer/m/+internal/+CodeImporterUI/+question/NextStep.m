

classdef NextStep<internal.CodeImporterUI.QuestionBase
    methods
        function obj=NextStep(env)
            id='NextStep';
            topic=message('Simulink:CodeImporterUI:Topic_Finish').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.CountInProgress=false;

            obj.Options={};
            obj.getAndAddOption(env,'ConfigProject_AddToProject');
            obj.DisplayFinishButton=true;
            obj.SinglePane=true;
            obj.HasHelp=false;
            obj.HasNext=false;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
        end
        function preShow(obj)


            preShow@internal.CodeImporterUI.QuestionBase(obj);

            codeImporter=obj.Env.CodeImporter;
            libRootFolder=codeImporter.qualifiedSettings.OutputFolder.char;
            libRootFolderHyperlink=message(...
            'Simulink:CodeImporterUI:OutputFolderCDHyperlink').getString;
            openLibHyperlinkMessage=message(...
            'Simulink:CodeImporterUI:OpenLibraryHyperlink').getString;

            model=fullfile(libRootFolder,(codeImporter.LibraryFileName+'.slx'));
            generatedFiles=['<ul><li>'...
            ,'<a href="matlab:open_system(''',model.char,''')">',openLibHyperlinkMessage,'</a>'...
            ,'</li>'];
            outputFolder=['<br/>'...
            ,'<li><a href="matlab:cd(''',libRootFolder,''')">',libRootFolderHyperlink,'</a></li>'];

            generatedFiles=[generatedFiles,outputFolder,'</ul>'];
            obj.QuestionMessage=message('Simulink:CodeImporterUI:Question_NextStep',generatedFiles).getString;
        end
    end
end
