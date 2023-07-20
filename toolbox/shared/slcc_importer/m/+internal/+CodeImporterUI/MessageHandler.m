classdef MessageHandler<handle




    properties
Env
    end
    methods
        function obj=MessageHandler(env)
            obj.Env=env;
        end
        function finish(obj)
            env=obj.Env;
            codeImporterInfo=env.CodeImporter;
            if~isempty(env)&&isvalid(env)&&~isempty(env.Gui)&&~isempty(env.Gui.Dlg)
                delete(env.Gui.Dlg);
                if isvalid(env)
                    env.Gui.Dlg=[];
                end
            end

            if codeImporterInfo.launchedFromBlocksetDesigner
                h=Simulink.BlocksetDesigner.Codeimporter();
                result.command='add_ccallerLibrary';
                result.data=h.create(codeImporterInfo);
                result.header.ParentId=codeImporterInfo.ParentIdForBlocksetDesigner;
                h.notifyUI(result);
            end
        end

        function sandboxOptions(obj,propName,propValue)
            obj.Env.CodeImporter.SandboxSettings.(propName)=propValue;
        end

        function testTypeOptions(obj,optionName,value)
            if strcmp(optionName,'UnitTest')&&value
                obj.Env.CodeImporter.TestType=...
                internal.CodeImporter.TestTypeEnum.UnitTest;
            end

            if strcmp(optionName,'IntegrationTest')&&value
                obj.Env.CodeImporter.TestType=...
                internal.CodeImporter.TestTypeEnum.IntegrationTest;
            end
        end

        function back(obj)
            env=obj.Env;
            if~isempty(env.CurrentQuestion.PreviousQuestionId)
                env.moveToPreviousQuestion();
                env.Gui.send_question(env.CurrentQuestion);
            end
        end

        function ready(obj)
            env=obj.Env;
            if isempty(env.CurrentQuestion)
                env.Gui.init;
                CustomCode=env.CodeImporter.CustomCode;
                if~isempty(CustomCode.SourceFiles)||...
                    ~isempty(CustomCode.InterfaceHeaders)
                    startNew(obj);
                end
            else
                q=env.CurrentQuestion;
                env.Gui.send_question(q);
            end
        end

        function startNew(obj)

            env=obj.Env;
            env.initAnswer();
            env.Gui.clickNext();
        end

        function load(obj)
            env=obj.Env;
            fileFilter={'*.json','JSON files (*.json)'};
            [file,folder]=uigetfile(fileFilter,'MultiSelect','off');
            success=false;
            if file
                fullFile=fullfile(folder,file);
                success=env.CodeImporter.load(fullFile);
            end


            if success

                env.init();


                env.State=internal.CodeImporterUI.State;


                env.loadAnswer();

                env.saveSettingsChecksum=cgxe('MD5AsString',env.CodeImporter.prepareSaveData());
                env.Gui.clickNext();
            end
        end

        function analyze(obj)
            env=obj.Env;
            env.Gui.send_command('start_spin');
            cleanupVar=onCleanup(@()env.Gui.send_command('stop_spin'));



            warningDetector=internal.CodeImporter.WarningDetector;









            resetOutputPath=obj.setOutputFolderPath();
            pathCleanUpVar=onCleanup(@()obj.resetOutputFolderPath(resetOutputPath));

            obj.Env.CodeImporter.parse();
            if obj.Env.CodeImporter.Options.ValidateBuild
                obj.Env.CodeImporter.build();
            end
            if~isempty(warningDetector.DetectedWarnings)
                env.handle_warning(warningDetector.DetectedWarnings);
            end
        end

        function create_sandbox(obj)



            env=obj.Env;
            env.Gui.send_command('start_spin');
            cleanupVar=onCleanup(@()env.Gui.send_command('stop_spin'));

            overwriteState="off";
            if env.State.OverwriteSandbox
                overwriteState="on";
            end



            warningDetector=internal.CodeImporter.WarningDetector;








            resetOutputPath=obj.setOutputFolderPath();
            pathCleanUpVar=onCleanup(@()obj.resetOutputFolderPath(resetOutputPath));

            obj.Env.CodeImporter.createSandbox('Overwrite',overwriteState);
            if~isempty(warningDetector.DetectedWarnings)
                env.handle_warning(warningDetector.DetectedWarnings);
            end
        end

        function update_sandbox(obj)

            env=obj.Env;
            env.Gui.send_command('start_spin');
            cleanupVar=onCleanup(@()env.Gui.send_command('stop_spin'));




            warningDetector=internal.CodeImporter.WarningDetector;








            resetOutputPath=obj.setOutputFolderPath();
            pathCleanUpVar=onCleanup(@()obj.resetOutputFolderPath(resetOutputPath));

            try
                obj.Env.CodeImporter.createSandbox('Overwrite',"off");
            catch e


                obj.Env.handle_error(e);
            end
            if~isempty(warningDetector.DetectedWarnings)
                env.handle_warning(warningDetector.DetectedWarnings);
            end


            env.Gui.send_question(env.CurrentQuestion);
        end

        function create(obj)
            env=obj.Env;
            env.Gui.send_command('start_spin');
            cleanupVar=onCleanup(@()env.Gui.send_command('stop_spin'));
            overwriteState="off";
            if env.State.OverwriteLibraryModel
                overwriteState="on";
            end




            warningDetector=internal.CodeImporter.WarningDetector;








            resetOutputPath=obj.setOutputFolderPath();
            pathCleanUpVar=onCleanup(@()obj.resetOutputFolderPath(resetOutputPath));


            env.CodeImporter.import('Functions',env.CodeImporter.FunctionsToImport,...
            'Types',env.CodeImporter.TypesToImport,...
            'Overwrite',overwriteState);
            if~isempty(warningDetector.DetectedWarnings)
                env.handle_warning(warningDetector.DetectedWarnings);
            end
        end
        function portspec_create(obj)
            env=obj.Env;
            env.Gui.send_command('start_spin');
            cleanupVar=onCleanup(@()env.Gui.send_command('stop_spin'));



            warningDetector=internal.CodeImporter.WarningDetector;
            env.CodeImporter.ParseInfo.getFunctions();
            if~isempty(warningDetector.DetectedWarnings)
                env.handle_warning(warningDetector.DetectedWarnings);
            end
        end

        function resetPath=setOutputFolderPath(obj)
            assert(~isempty(obj.Env.State.ProcessedOutputFolder));
            resetPath=obj.Env.CodeImporter.OutputFolder;
            obj.Env.CodeImporter.OutputFolder=obj.Env.State.ProcessedOutputFolder;
        end

        function resetOutputFolderPath(obj,resetPath)
            obj.Env.CodeImporter.OutputFolder=resetPath;
        end
    end
end


