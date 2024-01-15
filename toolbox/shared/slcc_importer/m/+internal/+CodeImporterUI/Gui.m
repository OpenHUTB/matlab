classdef Gui<handle
    properties
URL
DebugURL
ReportURL
MVURL
CodeURL
AdvancedOptionsURL
        Tag='Tag_SLCC_Wizard';
        SubScriptions={};
        Name='Custom Code Importer Wizard';
        ID=''
Env
MessageHandler

WebDDG
HelpArgs
Title
        Dlg=[]
        DlgPosition=[100,100,1000,600]
    end


    methods
        function obj=Gui(env)
            obj.Env=env;
            obj.MessageHandler=internal.CodeImporterUI.MessageHandler(env);
            connector.ensureServiceOn;
            rng('shuffle');
            obj.ID=sprintf('/%08x',uint32(rand*intmax('uint32')));
            webfolder='/toolbox/shared/slcc_importer/';
            obj.URL=connector.applyNonce(connector.getBaseUrl([webfolder,'index.html?',obj.ID]));
            obj.DebugURL=connector.applyNonce(connector.getBaseUrl([webfolder,'index-debug.html?',obj.ID]));
            obj.Title=message('Simulink:CodeImporterUI:Title').getString;
            obj.MVURL=connector.getBaseUrl('/toolbox/simulink/simulink/slmsgviewer/slmsgviewer.html');
        end
        function show(obj)
            if~isa(obj.Dlg,'DAStudio.Dialog')
                obj.Dlg=DAStudio.Dialog(obj);
                obj.Dlg.Position=obj.DlgPosition;
            end
            p=obj.Dlg.position;

            obj.Dlg.showNormal;
            obj.Dlg.show;
            obj.Dlg.position=p;
        end


        function start(obj)
            obj.unSubscribe;
            message.publish(obj.ID,struct('Type','command','Value','clearMCOS'));
            obj.SubScriptions{end+1}=message.subscribe(obj.ID,@obj.receive);
            obj.show();
        end
        function unSubscribe(obj)
            if~isempty(obj.SubScriptions)
                message.publish([obj.ID,'/destroy'],'destroy');
                for i=1:length(obj.SubScriptions)
                    message.unsubscribe(obj.SubScriptions{i});
                end
            end
        end
        function delete(obj)
            obj.unSubscribe;
        end


        function back(obj)
            env=obj.getEnvObj;
            if~isempty(env.CurrentQuestion.PreviousQuestionId)
                env.moveToPreviousQuestion();
                obj.send_question(env.CurrentQuestion);
            end
        end


        function clearMCOS(obj)
            obj.delete;
        end


        function switchTopic(obj,topic_id)
            if ischar(topic_id)
                topic_id=str2double(topic_id);
            end
            env=obj.getEnvObj;
            if nargin==1
                msg=env.LastAnswer;
                topic_id=str2double(msg.Param);
            end
            topic=env.QuestionTopics{topic_id};
            q=env.FirstQuestion;
            while~strcmp(q.Topic,topic)
                prev_q=q;
                q=q.NextQuestion;
                if isempty(q)||strcmp(q.Id,prev_q.Id)
                    break;
                end
            end
            env.CurrentQuestion=q;
            obj.send_question(q);
        end


        function clickNext(obj)

            obj.onNext;
        end


        function onchange(obj)
            env=obj.getEnvObj;
            q=env.CurrentQuestion;
            refresh=q.applyOnChange();
            if refresh&&~isempty(q)
                obj.send_question(q);
            end
        end


        function receive(obj,msg)
            try
                type=msg.Type;
                value=msg.Value;
                env=obj.getEnvObj;
                env.LastAnswer=msg;
                if strcmp('command',type)
                    if isfield(msg,'Param')
                        if strcmp(value,'switchTopic')
                            obj.(value)(msg.Param);
                        else
                            obj.MessageHandler.(value)(msg.Param);
                        end
                    else
                        obj.MessageHandler.(value);
                    end
                elseif strcmp(type,'sandboxOptions')
                    obj.MessageHandler.(type)(msg.Value,msg.Param);
                elseif strcmp(type,'testTypeOptions')
                    obj.MessageHandler.(type)(msg.Value,msg.Param);
                    q=env.CurrentQuestion;
                    if~isempty(q)
                        obj.send_question(q);
                    end
                elseif strcmp(type,'pickProjectFile')
                    obj.pickProjectFile();
                else

                    if obj.pushAnswer(msg)
                        if strcmp(type,'browseFile')
                            obj.browseFile(msg.Arg,false);
                        elseif strcmp(type,'browseFiles')
                            obj.browseFile(msg.Arg,true);
                        elseif strcmp(type,'browsePath')
                            obj.browsePath(msg.Arg);
                        else
                            obj.(type);
                        end
                    end
                end
            catch e
                obj.Env.handle_error(e);
                obj.Env.Gui.back;
            end
        end


        function browseFile(obj,optionName,multiSelect)
            env=obj.getEnvObj;
            q=env.CurrentQuestion;
            option=env.getOptionObj(optionName);
            fileFilter=option.FileFilter;
            if multiSelect
                [files,folder]=uigetfile(fileFilter,'MultiSelect','on');
            else
                [files,folder]=uigetfile(fileFilter,'MultiSelect','off');
            end
            if~iscell(files)&&~ischar(files)

                return;
            end
            for i=1:length(q.Options)
                o=q.Options{i};
                if strcmp(o.Id,optionName)
                    switch optionName
                    case{'ConfigCodeLibrary_IncludeFiles',...
                        'ConfigCodeLibrary_SourceFiles',...
                        'ConfigCodeLibrary_Libraries',...
                        'ManStubs'}

                        assert(multiSelect);
                        if~iscell(files)
                            files={files};
                        end

                        rootFolder=strip(env.CodeImporter.qualifiedSettings.OutputFolder,'"');
                        rootFolderChar=rootFolder.char;

                        fileToken=fullfile(folder,files);

                        currToken=[];
                        if~isempty(o.Answer)
                            currToken=internal.CodeImporter.tokenize(o.Answer);
                            fileTokens=[currToken,fileToken];
                        else
                            fileTokens=fileToken;
                        end
                        relPathFun=@(x)internal.CodeImporter.computeRelativePath(x,rootFolderChar);
                        if strcmpi(optionName,'ConfigCodeLibrary_IncludeFiles')
                            [includeDir,headerFile,extn]=...
                            fileparts(fileToken);

                            if~isempty(includeDir)&&~iscell(includeDir)

                                includeDir={includeDir};
                            end
                            relPathIncludeDir=cellfun(relPathFun,includeDir,'UniformOutput',false);
                            removeIdx=strcmp(relPathIncludeDir,'.');
                            relPathIncludeDir(removeIdx)=[];
                            env.CodeImporter.CustomCode.IncludePaths=...
                            unique([env.CodeImporter.CustomCode.IncludePaths,string(relPathIncludeDir)]);
                            includeFiles=strcat(headerFile,extn);
                            if~isempty(includeFiles)&&~iscell(includeFiles)
                                includeFiles={includeFiles};
                            end
                            includeFiles=[currToken,includeFiles];%#ok
                            includeFiles=unique(includeFiles,'stable');
                            o.Answer=strjoin(includeFiles,'\n');
                        else
                            relPathToFile=cellfun(relPathFun,fileTokens,'UniformOutput',false);
                            relPathToFile=unique(relPathToFile,'stable');
                            o.Answer=strjoin(relPathToFile,'\n');
                        end
                    case 'ConfigCodeLibrary_MetadataFile'
                        assert(~multiSelect&&ischar(files));
                        rootFolder=strip(env.CodeImporter.qualifiedSettings.OutputFolder,'"');
                        relMetadafilePath=...
                        internal.CodeImporter.computeRelativePath(...
                        fullfile(folder,files),rootFolder.char);
                        o.Answer=relMetadafilePath;
                    otherwise
                        assert(~multiSelect&&ischar(files));
                        o.Answer=fullfile(folder,files);
                    end
                    o.onChange;
                    break;
                end
            end
            env.Gui.send_question(q);
        end


        function browsePath(obj,optionName)
            env=obj.getEnvObj;
            q=env.CurrentQuestion;
            folder=uigetdir();
            if~ischar(folder)

                return
            end
            for i=1:length(q.Options)
                o=q.Options{i};
                if strcmp(o.Id,optionName)
                    rootFolder=strip(env.CodeImporter.qualifiedSettings.OutputFolder,'"');
                    rootFoderChar=rootFolder.char;
                    switch optionName
                    case{'ConfigCodeLibrary_IncludePaths'}
                        pathToken={folder};
                        if~isempty(o.Answer)&&ischar(o.Answer)
                            currPathToken=internal.CodeImporter.tokenize(o.Answer);
                            pathToken=[currPathToken,pathToken];%#ok
                        end

                        for idx=1:length(pathToken)

                            if pathToken{idx}(end-1:end)==[filesep,'.']
                                pathToken{idx}(end-1:end)=[];
                            end
                        end
                        relPathFun=@(x)internal.CodeImporter.computeRelativePath(x,rootFoderChar);
                        relPathToFolder=cellfun(relPathFun,pathToken,'UniformOutput',false);
                        relPathToFolder=unique(relPathToFolder,'stable');
                        o.Answer=strjoin(relPathToFolder,'\n');
                    case{'ConfigCodeLibrary_ProjectFolder'}
                        o.Answer=folder;
                    otherwise
                        relPathToFolder=internal.CodeImporter.computeRelativePath(folder,rootFoderChar);
                        o.Answer=relPathToFolder;
                    end
                    o.onChange;
                    break;
                end
            end
            env.Gui.send_question(q);
        end


        function pickProjectFile(obj)
            env=obj.Env;
            dlgTitle=message('Simulink:CodeImporterUI:ProjectDialogTitle').getString;
            [file,folder]=uigetfile('*.prj',dlgTitle);
            if isequal(file,0)

                return;
            end
            projectSuccess=env.CodeImporter.addToProject(fullfile(folder,file));
            successMsg=message('Simulink:CodeImporterUI:AddToProjectSuccessMsg').getString;
            successDlgTitle=message('Simulink:CodeImporterUI:AddToProjectSuccessDlg').getString;
            if(projectSuccess)
                msgbox(successMsg,successDlgTitle);
            end
        end


        function inferHeaderDependencies(obj)
            env=obj.Env;
            env.Gui.send_command('start_spin');
            cleanupVar=onCleanup(@()env.Gui.send_command('stop_spin'));
            q=env.CurrentQuestion;
            for i=1:length(q.Options)
                o=q.Options{i};
                if strcmp(o.Id,'ConfigCodeLibrary_IncludeFiles')
                    if~isempty(strip(o.Answer))
                        interfaceHdrName=message('Simulink:CodeImporterUI:Option_ConfigCodeLibrary_IncludeFiles').getString;
                        title=message('Simulink:CodeImporterUI:InferHdrConfirmationDlgTitle').getString;
                        msg=message('Simulink:CodeImporterUI:InferHdrConfirmationDlgMsg',interfaceHdrName).getString;
                        btnYes=message('Simulink:CodeImporterUI:InferHdrConfirmationDlgYesLabel').getString;
                        btnNo=message('Simulink:CodeImporterUI:InferHdrConfirmationDlgNoLabel').getString;
                        defbtn=btnYes;
                        selection=questdlg(msg,title,btnYes,btnNo,defbtn);
                        if strcmp(selection,btnNo)
                            return;
                        end
                    end
                    try
                        o.Answer=strjoin(env.CodeImporter.computeInterfaceHeaders(),'\n');
                    catch ME
                        env.handle_error(ME);
                    end
                    o.onChange;
                    break;
                end
            end
            env.Gui.send_question(q);
        end


        function onNext(obj)
            env=obj.getEnvObj;
            env.onNext();
            settingsChecksum=cgxe('MD5AsString',env.CodeImporter.prepareSaveData());
            if strcmp(env.CurrentQuestion.Id,'Start')&&isempty(env.saveSettingsChecksum)
                env.saveSettingsChecksum=settingsChecksum;
            elseif~strcmp(env.saveSettingsChecksum,settingsChecksum)
                autoFullFile=fullfile(env.AutoSaveFullFilePath,env.getAutoSaveFileName());
                env.CodeImporter.save(autoFullFile,'Overwrite','on');
                env.saveSettingsChecksum=settingsChecksum;
                env.isDirty=true;
            end
            next_q=env.moveToNextQuestion();
            if~isempty(next_q)
                obj.send_question(next_q);
            end
        end


        function success=pushAnswer(obj,msg)
            env=obj.getEnvObj;
            success=true;
            options=msg.Value;

            q_id='';
            if~isa(options,'struct')||isempty(options(1).option)
                success=false;
                return;
            end
            if~isempty(options)
                o=env.getOptionObj(options(1).option);
                q_id=o.Question_Id;
                if~isempty(q_id)
                    q=env.getQuestionObj(q_id);
                    for i=1:length(q.Options)
                        o=q.Options{i};
                        if strcmp(o.Type,'radio')
                            o.Answer=false;
                        end
                    end
                end
            end
            for i=1:length(options)
                option=options(i);
                option_id=option.option;
                value=option.value;
                o=env.getOptionObj(option_id);
                if~isempty(o)
                    if~strcmp(o.Question_Id,q_id)
                        error('Options should belongs to the same question');
                    end
                    if~isempty(o)
                        o.setAnswer(value);
                    end
                    if strcmp(o.Type,'checkbox')||strcmp(o.Type,'user_input')||...
                        strcmp(o.Type,'checklist_table')||...
                        strcmp(o.Type,'radiolist_table')||...
                        strcmp(o.Type,'path')||...
                        strcmp(o.Type,'paths')||...
                        strcmp(o.Type,'file')||...
                        strcmp(o.Type,'files')
                        o.Value=value;
                    end
                end
            end
        end


        function send_command(obj,command,msg)
            s.Type='command';
            s.Value=command;
            if nargin>2
                s.Message=msg;
            end
            message.publish(obj.ID,s);
        end


        function send_question(obj,q)
            q.preShow();
            obj.send_command('reset_log');
            env=obj.getEnvObj;
            if isempty(env)
                return;
            end
            s.QuestionTopics=env.QuestionTopics;
            s.CurrentTopic=q.Topic;
            s.Q.msg=obj.specialCharToJSON(q.getQuestionMessage);
            s.Q.hint=q.getHintMessage;
            s.Q.hasHelp=q.HasHelp;
            s.Q.hasBack=q.HasBack;
            s.Q.hasSave=q.HasSave;
            s.Q.hasNext=q.HasNext;
            s.Q.hasStartNew=q.HasStartNew;
            s.Q.hasLoad=q.HasLoad;
            s.Q.SinglePane=q.SinglePane;
            s.Q.DisplayRevertButton=q.DisplayRevertButton;
            s.Q.DisplayFinishButton=q.DisplayFinishButton;
            s.O=q.getOptions;
            s.Type='Question';
            s.ID=q.Id;
            s.HasPrevious=q.PreviousQuestionId;

            if strcmp(q.Id,'ConfigCodeImporter')
                if obj.Env.IsSLTest
                    s.IsSLTest=obj.Env.IsSLTest;
                    if obj.Env.CodeImporter.TestType==...
                        internal.CodeImporter.TestTypeEnum.UnitTest
                        s.TestTypeOption='UnitTest';
                    else
                        s.TestTypeOption='IntegrationTest';
                    end
                end
            end

            if strcmp(q.Id,'ConfigSandbox')
                s.SandboxOptions.CopySource=...
                env.CodeImporter.SandboxSettings.CopySourceFiles;
                s.SandboxOptions.RemovePragma=...
                env.CodeImporter.SandboxSettings.RemoveAllPragma;
                s.SandboxOptions.RemoveGVarDef=...
                env.CodeImporter.SandboxSettings.RemoveVariableDefinitionInHeader;
            end

            s.Progress=-1;
            if~isempty(q.TrailTable)
                s.TrailTable=q.TrailTable;
                s.TrailTable.Content=obj.specialCharToJSON(q.TrailTable.Content);
            end
            s.DisplayConfigDiff=q.DisplayConfigDiff;
            message.publish(obj.ID,s);
        end


        function init(obj,~)
            env=obj.getEnvObj;
            env.start;
            obj.send_question(env.CurrentQuestion);
            env.updateHeight();
        end


        function out=getEnvObj(obj)
            out=obj.Env;
        end


        function dlgstruct=getDialogSchema(obj,~)
            dlgstruct.DialogTitle=obj.Title;
            dlgstruct.CloseCallback='internal.CodeImporterUI.Gui.closeCallBack';
            dlgstruct.CloseArgs={obj};
            dlgstruct.IsScrollable=false;

            env=obj.getEnvObj;
            if env.Debug
                wizard.Url=obj.DebugURL;
                wizard.DisableContextMenu=false;
                wizard.EnableInspectorOnLoad=true;
            else
                wizard.Url=obj.URL;
                wizard.DisableContextMenu=true;
            end
            wizard.Type='webbrowser';
            wizard.WebKit=false;
            wizard.MinimumSize=[600,500];
            wizard.Tag='Tag_SLCC_Import_Wizard_Browser';

            dlgstruct.Items={wizard};
            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs=obj.HelpArgs;
            dlgstruct.MinMaxButtons=true;
            buttonSet={''};
            if isempty(buttonSet)
                if~isempty(obj.HelpArgs)
                    buttonSet={'OK','Help'};
                end
            end
            dlgstruct.StandaloneButtonSet=buttonSet;
            dlgstruct.ExplicitShow=true;
            dlgstruct.DispatcherEvents={};
            dlgstruct.DialogTag='SLCC_Import_Wizard_Dlg';

        end
    end


    methods(Static=true)
        function out=specialCharToJSON(str)
            out=strrep(str,newline,'<br/>');
        end


        function closeCallBack(gui)
            env=gui.getEnvObj;
            if~isempty(env)

                env.delete;
            end
        end


        function out=getWarningImage()
            out='<img style="height:1em" src="./release/wizard/images/dialog_info_32.png"/>';
        end


        function out=getLightBulbImage()
            out='<img style="height:1em" src="./release/wizard/images/lightbulb.png"/>';
        end


        function out=getWandImage()
            out='<div class="autoFillDiv"></div>';
        end
    end
end




