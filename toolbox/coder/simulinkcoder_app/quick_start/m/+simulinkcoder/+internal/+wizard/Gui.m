

classdef Gui<handle
    properties
URL
DebugURL
ReportURL
MVURL
CodeURL
AdvancedOptionsURL
        Tag='Tag_SLCoder_Wizard';
        SubScriptions={};
        Name='Code Generation Wizard';
        ID=''
        ModelHandle=[]
hModelCloseListener
        Tabs={'QuickStart','AdvancedOptions'}

WebDDG
HelpArgs
Title
        Dlg=[]
        DlgPosition=[100,100,1000,600]

        PostNameChangeId=''
    end

    methods
        function obj=Gui(modelName)
            obj.ModelHandle=simulinkcoder.internal.wizard.Wizard.getModelHandle(modelName);
            modelName=obj.ModelName;
            connector.ensureServiceOn;
            obj.ID=['/',modelName];
            obj.URL=connector.applyNonce(connector.getBaseUrl(['/toolbox/coder/wizard/web/index.html?',obj.ID]));
            obj.DebugURL=connector.applyNonce(connector.getBaseUrl(['/toolbox/coder/wizard/web/index-debug.html?',obj.ID]));
            obj.Title=message('SimulinkCoderApp:wizard:QuickStartTitle',modelName).getString;
            obj.ReportURL=connector.getBaseUrl('/toolbox/coder/wizard/web/blank_report.html');
            obj.AdvancedOptionsURL=connector.getBaseUrl(['/toolbox/coder/wizard/web/advancedOptions-debug.html?',obj.ID]);
            obj.MVURL=connector.getBaseUrl('/toolbox/simulink/simulink/slmsgviewer/slmsgviewer.html');

            obj.registerNameChangeCallback;
        end
        function out=ModelName(obj)
            out='';
            if~isempty(obj.ModelHandle)&&isValidSlObject(slroot,obj.ModelHandle)
                out=get_param(obj.ModelHandle,'Name');
            end
        end
        function showInDialog(obj)
            if~isa(obj.Dlg,'DAStudio.Dialog')
                obj.Dlg=DAStudio.Dialog(obj);
                obj.Dlg.Position=obj.DlgPosition;
            end
            p=obj.Dlg.position;

            obj.Dlg.showNormal;
            obj.Dlg.show;
            obj.Dlg.position=p;
        end

        function show(obj)




            currentCS=getActiveConfigSet(obj.ModelName);
            currentCS.closeDialog();

            obj.showInDialog();
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

            if isValidSlObject(slroot,obj.ModelHandle)
                id=obj.PostNameChangeId;
                try
                    modelObject=get_param(obj.ModelHandle,'Object');
                    if modelObject.hasCallback('PostNameChange',id)
                        Simulink.removeBlockDiagramCallback(obj.ModelHandle,'PostNameChange',id);
                    end
                catch


                end
            end
        end

        function ready(obj)
            env=obj.getEnvObj;
            if isempty(env.CurrentQuestion)
                obj.init;
            else
                q=env.CurrentQuestion;
                obj.send_question(q);
            end
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
        function revertCS(obj)
            env=obj.getEnvObj;
            env.revertConfigSet;

            obj.switchTopic(1);
        end
        function viewConfig(obj)
            env=obj.getEnvObj;
            dae=daexplr;
            imme=DAStudio.imExplorer(dae);
            cs=getActiveConfigSet(env.ModelName);
            imme.selectTreeViewNode(cs);
        end
        function generate(obj)
            env=obj.getEnvObj;
            obj.send_command('reset_log');
            obj.onNext;
            obj.send_command('start_spin');
            try
                env.applyAndGenerate;
            catch e
                obj.send_command('stop_spin');
                obj.send_command('update_log',e.message);
                rethrow(e);
            end
            obj.send_command('stop_spin');
        end
        function analyze(obj)
            env=obj.getEnvObj;
            obj.send_command('start_spin');
            stageName=message('RTW:wizard:AnalyzeModelStage').getString;
            myStage=Simulink.output.Stage(stageName,'ModelName',env.ModelName,'UIMode',env.GuiEntry);%#ok<NASGU>            
            try


                slInternal('analyzeModelFromApp',env);
            catch e
                obj.send_command('stop_spin');
                obj.send_command('update_log',e.message);
                Simulink.output.error(e);
                if strcmp(e.identifier,'RTW:wizard:AutosarMappingNotReady')
                    q=env.moveToPreviousQuestion;
                    obj.send_question(q);
                else
                    q=env.getQuestionObj('Analyze');

                    q.changeToFailedState;
                    obj.send_question(q);
                end
                return;
            end
            obj.send_command('stop_spin');
            q=env.CurrentQuestion;
            q.updateStateAfterAnalyze();
            obj.send_question(q);



            if env.GuiEntry
                env.Gui.show();
            end
        end
        function launchCodeStyle(obj)
            env=obj.getEnvObj;
            try
                configset.highlightParameter(env.ModelName,{'IndentStyle','IndentSize'});
            catch e
                rethrow(e);
            end
        end
        function launchFPC(obj)
            env=obj.getEnvObj;
            obj.send_command('start_spin');
            try
                if env.isSubsystemBuild
                    RTW.ConfigSubsystemBuild(env.SourceSubsystem);
                else
                    configModelBuild(env.ModelName);
                end
            catch e
                obj.send_command('stop_spin');
                rethrow(e);
            end
            obj.send_command('stop_spin');
            function configModelBuild(model)
                if~ecoderinstalled()
                    DAStudio.error('RTW:makertw:licenseUnavailable',...
                    get_param(hConfigSet,'SystemTargetFile'));
                end
                model=get_param(model,'handle');
                if strcmp(env.Flavor,'C')
                    coder.internal.launchCFunctionPrototypeControl(model,[]);
                elseif strcmp(env.Flavor,'CppEncap')
                    coder.internal.launchCPPFunctionPrototypeControl(model)
                elseif strcmp(env.Flavor,'AUTOSAR')
                    assert(autosarinstalled(),'AUTOSAR Blockset is not installed!');
                    autosar_ui_launch(env.ModelName);
                end
            end
        end
        function launchCGA(obj)
            env=obj.getEnvObj;
            obj.send_command('start_spin');
            try
                if env.isSubsystemBuild
                    system=env.SourceSubsystem;
                else
                    system=env.ModelName;
                end
                coder.advisor.internal.runBuildAdvisor(system,true,false);
            catch e
                obj.send_command('stop_spin');
                rethrow(e);
            end
            obj.send_command('stop_spin');
        end
        function finish(obj)
            env=obj.getEnvObj;
            if~isempty(env)&&~isempty(env.Gui)&&~isempty(env.Gui.Dlg)
                delete(env.Gui.Dlg);
                env.Gui.Dlg=[];
            end


            if coder.internal.isSLXFile(get_param(env.ModelName,'Handle'))
                cp=simulinkcoder.internal.CodePerspective.getInstance;
                cp.turnOnPerspective(env.ModelName);
            end


            obj.cleanup;
        end
        function cleanup(obj)
            env=obj.getEnvObj;
            if~isempty(env)

                set_param(env.ModelName,'CoderWizard',[]);
            end
        end
        function onchangeTree(obj,msg)
            env=obj.getEnvObj;
            o_id=msg.param;
            value=msg.value;
            o=env.getOptionObj(o_id);
            o.setAnswer(value);
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
        function pushBuildStatus(obj,bsn)








            obj.send_command('updateBuildStatus',...
            struct('CurrentModel',bsn.mdlCounter,...
            'TotalModels',bsn.nTotalMdls));
        end
        function getConfigChange(obj)
            env=obj.getEnvObj;
            [comp,params,oldValue,newValue]=env.getConfigChange();
            if isempty(params)
                obj.send_command('showConfigChange',...
                struct('Number',length(comp),...
                'Value',[]));
            else
                obj.send_command('showConfigChange',...
                struct('Number',length(comp),...
                'Value',struct('c',comp,'p',params,'o',oldValue,'n',newValue)));
            end
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
            type=msg.Type;
            value=msg.Value;
            env=obj.getEnvObj;
            env.LastAnswer=msg;
            if strcmp(type,'SingleMultiInstanceQuestion')

                env.MultiInstance=value;
            elseif strcmp('command',type)
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
            env=obj.getEnvObj;
            env.onNext();
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
                    if strcmp(o.Type,'checkbox')
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
            s.Q.rootModel=env.ModelName;
            s.Q.hint=q.getHintMessage;
            s.Q.hasHelp=q.HasHelp;
            s.Q.hasBack=q.HasBack;
            s.Q.SinglePane=q.SinglePane;
            s.Q.DisplayRevertButton=q.DisplayRevertButton;
            s.Q.DisplayFinishButton=q.DisplayFinishButton;
            s.O=q.getOptions;
            s.Type='Question';
            s.ID=q.Id;
            s.HasPrevious=q.PreviousQuestionId;



            if isempty(env.MultiInstance)&&strcmp(q.Id,'Flavor')
                reusable=get_param(env.ModelHandle,'CodeInterfacePackaging');
                m=strcmp(reusable,'Reusable function');
                env.MultiInstance=m;
                s.MultiInstance=m;
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
            out='';
            if isValidSlObject(slroot,obj.ModelHandle)
                out=get_param(obj.ModelName,'CoderWizard');
            end
        end
        function openReport(obj,url)
            obj.ReportURL=url;
            if rtwprivate('rtwinbat')
                disp('# Code Generation Report is not launched in BaT or during test execution. The report will be launched in internal browser.');
                return
            end
            obj.show();
            obj.Dlg.refresh;
            if isa(obj.Dlg,'DAStudio.Dialog')
                obj.Dlg.setActiveTab('Production_Code_App_tag',obj.getTabIdx('Code')-1);
            end

            obj.Dlg.evalBrowserJS('Production_Code_App_CodeTab_tag','top.location.reload();');
        end
        function dlgstruct=getDialogSchema(obj,~)
            dlgstruct.DialogTitle=obj.Title;
            dlgstruct.CloseCallback='simulinkcoder.internal.wizard.Gui.closeCallBack';
            dlgstruct.CloseArgs={obj};


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
            wizard.Tag='Tag_CodeGen_Wizard_Browser';

            if env.IsCodeGenReady
                tabcontainer.Type='tab';
                obj.Tabs={'QuickStart','AdvancedOptions'};
                tabcontainer.Tabs=cell(size(obj.Tabs));





                quickstartTab.Name=message('RTW:wizard:Settings').getString;
                quickstartTab.Items={wizard};






                advancedOptions.Url=connector.applyNonce(obj.AdvancedOptionsURL);
                advancedOptions.Type='webbrowser';
                advancedOptions.WebKit=true;
                advancedOptionsTab.Name=message('RTW:wizard:MoreSettings').getString;
                advancedOptionsTab.Items={advancedOptions};


                tabcontainer.Tabs{obj.getTabIdx('QuickStart')}=quickstartTab;
                tabcontainer.Tabs{obj.getTabIdx('AdvancedOptions')}=advancedOptionsTab;
                tabcontainer.Tag='Production_Code_App_tag';
                dlgstruct.Items={tabcontainer};
            else
                dlgstruct.Items={wizard};
            end
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

        end

        function idx=getTabIdx(obj,tabName)
            [~,idx]=ismember(tabName,obj.Tabs);
        end

        function registerNameChangeCallback(obj)
            modelHandle=obj.ModelHandle;
            bdObj=get_param(modelHandle,'Object');
            modelName=get_param(modelHandle,'Name');
            id='NameChangeQuickStart';
            if isempty(obj.PostNameChangeId)
                obj.PostNameChangeId=id;
            end
            if~bdObj.hasCallback('PostNameChange',id)
                Simulink.addBlockDiagramCallback(modelName,'PostNameChange',...
                id,@()simulinkcoder.internal.wizard.Gui.modelNameChangeCallback(modelHandle));
            end
        end
    end
    methods(Static=true)
        function out=specialCharToJSON(str)
            out=strrep(str,char(10),'<br/>');
        end
        function LaunchCodeStyle(model)
            env=get_param(model,'CoderWizard');
            obj=env.Gui;
            obj.launchCodeStyle;
        end
        function LaunchFPC(model)
            env=get_param(model,'CoderWizard');
            obj=env.Gui;
            obj.launchFPC;
        end
        function LaunchCGA(model)
            env=get_param(model,'CoderWizard');
            obj=env.Gui;
            obj.launchCGA;
        end
        function closeCallBack(gui)
            gui.cleanup;
        end
        function out=getWarningImage()
            out='<div class="warningDiv"></div>';
        end
        function out=getLightBulbImage()
            out='<div class="lightbulbDiv"></div>';
        end
        function modelNameChangeCallback(modelHandle)
            env=get_param(modelHandle,'CoderWizard');
            if isempty(env)||isempty(env.Gui)
                return;
            end
            oldId=env.Gui.PostNameChangeId;
            modelObject=get_param(modelHandle,'Object');
            if modelObject.hasCallback('PostNameChange',oldId)
                Simulink.removeBlockDiagramCallback(modelHandle,'PostNameChange',oldId);
            end
            newId=[get_param(modelHandle,'Name'),'_QuickStart'];
            env.Gui.PostNameChangeId=newId;
            if~modelObject.hasCallback('PostNameChange',newId)
                Simulink.addBlockDiagramCallback(modelHandle,'PostNameChange',newId,@()simulinkcoder.internal.wizard.Gui.modelNameChangeCallback(modelHandle));
            end
            newName=get_param(modelHandle,'Name');
            env.Gui.Title=[message('RTW:wizard:QuickStart').getString,': ',newName];
            if env.GuiEntry&&isa(env.Gui.Dlg,'DAStudio.Dialog')
                env.Gui.Dlg.refresh;
            end
        end
    end
end




