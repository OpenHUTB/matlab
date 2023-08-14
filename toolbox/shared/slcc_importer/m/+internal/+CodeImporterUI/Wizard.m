


classdef Wizard<handle
    properties
QuestionMap
OptionMap
        QuestionTopics={}
        QuestionStack={}
        OptionStack={}
        CurrentQuestion=[]
        FirstQuestionId=''
        MaxHeight=0
        Debug=false
Gui
State
LastAnswer
CodeImporter
IsSLTest
        AutoSaveFullFilePath=''
        noSaveOnClose=false
saveSettingsChecksum
        isDirty=false
    end
    properties(Transient=true)
GuiEntry
    end
    methods
        function env=Wizard(firstQuestionId)
            if nargin<2
                firstQuestionId='Start';
            end

            env.State=internal.CodeImporterUI.State();
            env.Gui=internal.CodeImporterUI.Gui(env);
            env.FirstQuestionId=firstQuestionId;
            env.GuiEntry=true;

            if internal.CodeImporter.Tools.isFolderWritable(pwd)
                env.AutoSaveFullFilePath=pwd;
            end
        end

        function registerQuestion(env,q)
            env.QuestionMap(q.Id)=q;
            if~isempty(q.Topic)&&~ismember(q.Topic,env.QuestionTopics)
                env.QuestionTopics{end+1}=q.Topic;
            end
        end

        function registerOption(env,o)
            env.OptionMap(o.Id)=o;
        end
        function out=getOptionAnswer(env,option_id)
            out=-1;
            if env.OptionMap.isKey(option_id)
                o=env.OptionMap(option_id);
                out=o.Answer;
            end
        end
        function out=getOptionList(env,question_id)
            if env.QuestionMap.isKey(question_id)
                out=env.QuestionMap(question_id).Options;
            else
                error([question_id,' is not in question map.']);
            end
        end
        function out=getOptionParam(env,option_id)
            tmp=env.OptionMap(option_id);
            out=tmp.MsgParam;
        end
        function out=getOption(env,option_id)
            out=env.OptionMap(option_id);
        end
        function out=getNextQuestionId(env,option_id)
            if env.OptionMap.isKey(option_id)
                tmp=env.OptionMap(option_id);
                out=tmp.NextQuestion_Id;
            else
                error([option_id,' has not been registered in OptionMap']);
            end
        end
        function reset(env)
            env.init();
            env.updateHeight();
        end
        function deleteOption(env,option_id)
            if env.OptionStack.isKey(option_id)
                o=env.OptionStack(option_id);
                env.OptionStack.remove({option_id});
                o.delete;
            end
        end
        function out=getQuestionObj(env,question_id)
            out=[];
            if env.QuestionStack.isKey(question_id)
                out=env.QuestionStack(question_id);
            elseif env.QuestionMap.isKey(question_id)
                out=env.QuestionMap(question_id);
            end
        end
        function out=getOptionObj(env,option_id)
            out=[];
            if env.OptionStack.isKey(option_id)
                out=env.OptionStack(option_id);
            elseif env.OptionMap.isKey(option_id)
                out=env.OptionMap(option_id);
            end
        end
        function prev_q=moveToPreviousQuestion(env)
            q=env.CurrentQuestion;
            if~isempty(q)
                if isempty(q.PreviousQuestionId)
                    env.CurrentQuestion=[];
                else
                    env.CurrentQuestion=env.QuestionMap(q.PreviousQuestionId);
                end
            end
            prev_q=env.CurrentQuestion;
        end
        function next_q=moveToNextQuestion(env)
            q=env.CurrentQuestion;
            next_q=[];
            if~isempty(q)
                next_q=q.getNextQuestion();
                if~isempty(next_q)
                    q.NextQuestionId=next_q.Id;


                    if~strcmp(next_q.Id,q.Id)
                        next_q.PreviousQuestionId=q.Id;
                    end
                    env.CurrentQuestion=next_q;
                end
            end
        end
        function pushAnswer(env,option_id,answer)
            if env.OptionStack.isKey(option_id)
                o=env.OptionStack(option_id);
                o.setAnswer(answer);
            else
                error(['Option ',option_id,' is not displayed yet.']);
            end
        end
    end
    methods(Hidden)
        function updateOption(env)

            questions=env.QuestionMap.keys;
            for i=1:length(questions)
                q=questions{i};
                option=env.QuestionMap(q).Options;
                for j=1:length(option)
                    option{j}.Question_Id=q;
                end
            end
        end
        function updateTopics(env)
            questions=env.QuestionMap.keys;
            for i=1:length(questions)
                q=questions{i};
                env.registerQuestion(q);
            end
        end
        function out=updateHeight(env,question_id)
            if nargin<2
                question_id=env.FirstQuestionId;
            end
            q=env.getQuestionObj(question_id);
            option=env.getOptionList(question_id);
            max_child_height=-1;
            if isempty(option)
                out=0;
            else
                for i=1:length(option)
                    nextQ=env.getNextQuestionId(option{i}.Id);
                    child_height=env.updateHeight(nextQ);
                    if max_child_height<child_height
                        max_child_height=child_height;
                    end
                end
                out=max_child_height+1;
            end
            if~q.CountInProgress

                out=out-1;
            end
            tmp=env.QuestionMap(question_id);
            tmp.Height=out;
            env.QuestionMap(question_id)=tmp;
            env.MaxHeight=max(env.MaxHeight,out);
        end
        function out=getHeight(env,question_id)
            q=env.QuestionMap(question_id);
            out=q.Height;
        end
        function onNext(env)
            q=env.CurrentQuestion;
            try
                q.onNext();
            catch e
                env.handle_error(e);
                env.Gui.back;
            end
        end
        function handle_error(env,e)
            myStage=Simulink.output.Stage('CodeImporter','ModelName',env.CodeImporter.LibraryFileName,'UIMode',true);
            Simulink.output.error(e);
            myStage.delete;


            instance=slmsgviewer.Instance(env.CodeImporter.LibraryFileName);
            id=instance.m_ComponentId;
            if~strcmp(id,'0')
                open_system(env.CodeImporter.LibraryFileName);
            end
        end
        function handle_warning(env,w)
            myStage=Simulink.output.Stage('CodeImporter','ModelName',env.CodeImporter.LibraryFileName,'UIMode',true);
            if length(w)>1
                for i=1:length(w)
                    MSLDiagnostic(w(i).identifier,w(i).arguments{:}).reportAsWarning;
                end
            else
                MSLDiagnostic(w.identifier,w.arguments{:}).reportAsWarning;
            end
            env.displayMSV();
            myStage.delete;
        end

        function out=start(env)
            env.init();
            out=env.getQuestionObj(env.FirstQuestionId);
            env.CurrentQuestion=out;
        end
        function out=FirstQuestion(env)
            if env.QuestionMap.isKey(env.FirstQuestionId)
                out=env.QuestionMap(env.FirstQuestionId);
            else
                out=env.start;
            end
        end

        function out=getSummary(env)
            out='';
            q=env.FirstQuestion;
            while~isempty(q)
                str=q.getSummary();
                if~isempty(str)
                    out=[out,q.getSummary(),'<br/>'];%#ok<AGROW>
                end


                prev_q=q;
                q=q.NextQuestion;
                if isempty(q)||strcmp(q.Id,prev_q.Id)
                    break;
                end
            end
        end

        function delete(env)
            delete(env.Gui);
            env.saveSettingsToFile;
            slmsgviewer.removeTab(env.CodeImporter.LibraryFileName);
        end

        function ret=getAutoSaveFileName(env)
            ret=[char(env.CodeImporter.LibraryFileName),'_import_autosave.json'];
        end
    end
    methods(Hidden)
        function init(env)
            env.QuestionMap=containers.Map;
            env.OptionMap=containers.Map;
            env.QuestionStack=containers.Map;
            env.OptionStack=containers.Map;

            internal.CodeImporterUI.question.Start(env);
            internal.CodeImporterUI.question.ConfigCodeImporter(env);
            internal.CodeImporterUI.question.ConfigCodeLibrary(env);

            internal.CodeImporterUI.question.WhatToImportAnalyze(env);
            internal.CodeImporterUI.question.OptionsGlobalIO(env);
            internal.CodeImporterUI.question.WhatToImportFunction(env);
            internal.CodeImporterUI.question.PortSpecificationsMapping(env);
            internal.CodeImporterUI.question.WhatToImportType(env);

            internal.CodeImporterUI.question.Finish(env);
            internal.CodeImporterUI.question.ConfigUpdateMode(env);
            internal.CodeImporterUI.question.CreateTestHarness(env);
            internal.CodeImporterUI.question.NextStep(env);


            if isa(env.CodeImporter,'sltest.CodeImporter')
                internal.CodeImporterUI.question.ConfigSandbox(env);
                internal.CodeImporterUI.question.WhatToImportAnalyzeSandbox(env);
                internal.CodeImporterUI.question.WhatToImportOverwriteSandbox(env);
                internal.CodeImporterUI.question.WhatToImportFinishSandbox(env);
            end

            env.updateOption;
            env.initAnswer;
        end
        function initAnswer(obj)

            keys=obj.OptionMap.keys;
            for i=1:length(keys)
                o=obj.OptionMap(keys{i});
                if~isempty(o.Property)
                    if isprop(obj.CodeImporter,o.Property)
                        o.Answer=obj.CodeImporter.(o.Property);
                        if strcmp(o.Property,'OutputFolder')&&isempty(strip(char(o.Answer)))

                            o.Answer='.';
                        end
                    end
                    if isprop(obj.CodeImporter.CustomCode,o.Property)
                        ccProp=obj.CodeImporter.CustomCode.(o.Property);
                        if isstring(ccProp)
                            ccProp=strjoin(ccProp,'\n');
                        end
                        o.Answer=ccProp;
                    end
                end
            end
        end

        function loadAnswer(obj)
            keys=obj.OptionMap.keys;
            for i=1:length(keys)
                o=obj.OptionMap(keys{i});
                if~isempty(o.Property)
                    if isprop(obj.CodeImporter,o.Property)
                        o.Answer=obj.CodeImporter.(o.Property);
                    end
                    if isprop(obj.CodeImporter.CustomCode,o.Property)
                        ccProp=obj.CodeImporter.CustomCode.(o.Property);
                        if isstring(ccProp)
                            ccProp=strjoin(ccProp,'\n');
                        end
                        o.Answer=ccProp;
                    end
                    if isprop(obj.CodeImporter.Options,o.Property)
                        o.Answer=obj.CodeImporter.Options.(o.Property);
                    end
                    if isprop(obj.State,o.Property)
                        o.Answer=obj.State.(o.Property);
                    end
                end
            end
        end

        function saveSettingsToFile(env)
            if env.noSaveOnClose||isempty(env.saveSettingsChecksum)
                return;
            end
            settingsChecksum=cgxe('MD5AsString',env.CodeImporter.prepareSaveData());
            if~env.isDirty&&strcmp(env.saveSettingsChecksum,settingsChecksum)

                return;
            end

            selection=env.constructConfirmDlg();
            btnYes=message('Simulink:CodeImporterUI:ConfirmationDialogButtonYesLabel').getString;
            if strcmp(selection,btnYes)
                fileFilter={'*.json','JSON files (*.json)'};
                dlgTitle=message('Simulink:CodeImporterUI:SaveDialogTitle').getString;
                [file,path]=uiputfile(fileFilter,dlgTitle);
                if~isequal(file,0)
                    fullFile=fullfile(path,file);
                    env.CodeImporter.save(fullFile,'Overwrite','on');

                    autoFullFile=fullfile(env.AutoSaveFullFilePath,env.getAutoSaveFileName());
                    if isfile(autoFullFile)
                        delete(autoFullFile);
                    end
                end
            end
        end
    end
    methods(Static)
        function displayMSV()
            slmsgviewer.Instance.show;
        end
        function out=startup(varargin)
            out=internal.CodeImporterUI.Wizard('Start');
            out.Gui.start;
        end
        function ret=constructConfirmDlg()
            title=message('Simulink:CodeImporterUI:ConfirmationDialogTitle').getString;
            msg=message('Simulink:CodeImporterUI:ConfirmationDialogMsg').getString;
            btnYes=message('Simulink:CodeImporterUI:ConfirmationDialogButtonYesLabel').getString;
            btnNo=message('Simulink:CodeImporterUI:ConfirmationDialogButtonNoLabel').getString;
            defbtn=btnYes;
            ret=questdlg(msg,title,btnYes,btnNo,defbtn);
        end
    end
end
