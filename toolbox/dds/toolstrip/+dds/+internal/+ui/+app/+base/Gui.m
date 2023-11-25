classdef Gui<handle
    properties
        ID=''
        Dlg=[]
Env

URL
DebugURL
        Subscriptions={};
Title
        DlgPosition=[100,100,1000,600]
HelpArgs
        Tag;
    end

    methods(Access=public)
        function obj=Gui(env,ID,guiTag,title)

            connector.ensureServiceOn;

            obj.ID=ID;
            obj.Title=title;
            obj.Tag=guiTag;
            webfolder='/toolbox/dds/toolstrip/+dds/+internal/+ui/+app/web/';
            obj.URL=connector.applyNonce(connector.getBaseUrl([webfolder,'index.html?',obj.ID]));
            obj.DebugURL=connector.applyNonce(connector.getBaseUrl([webfolder,'index-debug.html?',obj.ID]));
...
...
...
...
...


            obj.Env=env;
        end
        function showInDialog(obj)

            if~isa(obj.Dlg,'DAStudio.Dialog')
                obj.Dlg=DAStudio.Dialog(obj);
                obj.Dlg.position=obj.DlgPosition;
            end

            p=obj.Dlg.position;

            obj.Dlg.showNormal;
            obj.Dlg.show;

            obj.Dlg.position=p;
        end

        function show(obj)

            obj.showInDialog();
        end

        function start(obj)

            obj.unsubscribe;
            message.publish(obj.ID,struct('Type','command','Value','clearMCOS'));
            obj.Subscriptions{end+1}=message.subscribe(obj.ID,@obj.receive);


            obj.show();
        end
        function unsubscribe(obj)

            if isvalid(obj)&&~isempty(obj.Subscriptions)
                message.publish([obj.ID,'/destroy'],'destroy');
                for i=1:length(obj.Subscriptions)
                    message.unsubscribe(obj.Subscriptions{i});
                end
            end
        end
        function delete(~)
        end
        function cleanup(obj)

            if~isvalid(obj)
                return;
            end


            obj.unsubscribe;



            if isa(obj.Env,'dds.internal.ui.app.quickstart.Wizard')
                obj.Env.Manager.unregisterQuickStartWizard(obj.Env.ModelHandle);
            end

            obj.Env.delete;

            obj.delete;
        end
        function receive(obj,msg)





            type=msg.Type;
            value=msg.Value;


            env=obj.Env;


            env.LastAnswer=msg;



            if strcmp('command',type)
                if isfield(msg,'Param')
                    obj.(value)(msg.Param);
                else
                    obj.(value);
                end

            else

                if obj.pushAnswer(msg)
                    obj.(type);
                end
            end
        end
        function onNext(obj)



            env=obj.Env;
            ret=env.onNext();
            if ret<0
                nextQ=env.CurrentQuestion;
            else
                nextQ=env.moveToNextQuestion();
            end


            if~isempty(nextQ)
                obj.sendQuestion(nextQ);
            end
        end
        function success=pushAnswer(obj,msg)






            env=obj.Env;
            success=true;

            options=msg.Value;
            qId='';
            if(~isempty(options)&&~isa(options,'struct'))
                if iscell(options)




                    optionsWithValue=cellfun(@(x)isfield(x,'value'),options);
                    options=cell2mat(options(optionsWithValue));
                elseif isempty(options(1).option)



                    success=false;
                    return
                end
            end
            if~isempty(options)
                o=env.getOption(options(1).option);
                qId=o.QuestionId;
            end


            for i=1:length(options)
                option=options(i);
                optionId=option.option;
                value=option.value;
                o=env.getOption(optionId);
                if~isempty(o)
                    assert(strcmp(o.QuestionId,qId),'Options should belong to the same question');
                    o.setAnswer(value);
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
        function sendQuestion(obj,q)





            q.preShow();


            env=obj.Env;
            if isempty(env)
                return
            end


            s.QuestionTopics=env.QuestionTopics;
            s.CurrentTopic=q.Topic;
            s.Q=q.getInformation;
            s.O=q.getOptions;
            s.Type='Question';
            s.ID=q.Id;
            s.HasPrevious=q.PreviousQuestionId;

            if~isempty(q.TrailTable)
                s.TrailTable=q.TrailTable;
                s.TrailTable.Content=obj.specialCharToJSON(q.TrailTable.Content);
            end


            message.publish(obj.ID,s);
        end
        function init(obj,~)

            env=obj.Env;
            env.start;
            obj.sendQuestion(env.CurrentQuestion);
        end
        function dlgstruct=getDialogSchema(obj,~)


            dlgstruct.DialogTitle=obj.Title;

            dlgstruct.CloseCallback='dds.internal.ui.app.base.Gui.closeCallBack';
            dlgstruct.CloseArgs={obj};


            env=obj.Env;
            if env.Debug
                wizard.Url=obj.DebugURL;
                wizard.DisableContextMenu=false;
                wizard.EnableInspectorOnLoad=true;
            else
                wizard.Url=obj.URL;
                wizard.DisableContextMenu=true;
            end
            wizard.Type='webbrowser';
            wizard.MinimumSize=[600,500];
            wizard.Tag=[obj.Tag,'_Browser'];

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
            dlgstruct.Sticky=true;
        end

        function back(obj)


            env=obj.Env;
            if~isempty(env.CurrentQuestion.PreviousQuestionId)
                env.moveToPreviousQuestion();
                obj.sendQuestion(env.CurrentQuestion);
            end
        end
    end

    methods(Access=private)
        function ready(obj)



            env=obj.Env;
            if isempty(env.CurrentQuestion)
                obj.init;
            else
                q=env.CurrentQuestion;
                obj.sendQuestion(q);
            end
        end
        function clearMCOS(obj)
            obj.delete;
        end
        function finish(obj)


            env=obj.Env;
            env.IsWizardFinished=true;
            try
                env.IsWizardFinished=env.finish();
            catch e
                sldiagviewer.reportError(e);
            end


            if env.IsWizardFinished
                if~isempty(env)&&~isempty(env.Gui)&&~isempty(env.Gui.Dlg)
                    delete(obj.Dlg);
                end
                obj.cleanup;
            end
        end
        function switchTopic(obj,topicId)





            if ischar(topicId)
                topicId=str2double(topicId);
            end
            env=obj.Env;
            if nargin==1
                msg=env.LastAnswer;
                topicId=str2double(msg.Param);
            end

            topic=env.QuestionTopics{topicId};


            q=env.QuestionMap('Component');
            while~strcmp(q.Topic,topic)
                prevQ=q;
                q=q.NextQuestion;
                if isempty(q)||strcmp(q.Id,prevQ.Id)
                    break;
                end
            end


            env.CurrentQuestion=q;
            obj.sendQuestion(q);
        end

        function clickNext(obj)

            obj.onNext;
        end
        function launchHelp(obj)


            env=obj.Env;
            q=env.CurrentQuestion;
            helpViewID=q.getHelpViewID();
            helpview(fullfile(docroot,'dds','helptargets.map'),helpViewID);
        end
        function onchange(obj)

            env=obj.Env;
            q=env.CurrentQuestion;


            refresh=q.applyOnChange();


            if refresh&&~isempty(q)
                obj.sendQuestion(q);
            end
        end
        function xmlSelect(obj)
            obj.Env.xmlSelect;
        end

        function dataDictionarySelect(obj)
            obj.Env.dataDictionarySelect;
        end

    end
    methods(Static=true,Hidden)
        function out=specialCharToJSON(str)
            out=strrep(str,newline,'<br/>');
        end

        function closeCallBack(gui)

            gui.cleanup;
        end
    end
end




