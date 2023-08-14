


classdef QuestionBase<handle
    properties
        Id=''
        Question_Message_Id=''
        Hint_Message_Id=''
        QuestionMessage=''
        MsgParam=''
        HintMessage=''
        Options={}
        PreviousQuestionId=''
        NextQuestionId=''
        DisplayFinishButton=false
        TrailTable=[]
        DisplayConfigDiff=false
        DisplayRevertButton=false
        Topic=''
        CountInProgress=true
        HasHelp=true
        HasBack=true
        HasNext=true
        HasSave=false
        HasStartNew=false
        HasLoad=false
        SinglePane=false
Env
        Height=0;
        UpdateLogRequiredIndex=10000000;
        UpdateLogOptionalIndex=10000000;
        HasHintMessage=true;
        HasSummaryMessage=true;
    end
    methods
        function obj=QuestionBase(id_str,topic,env)
            obj.Id=id_str;
            obj.Question_Message_Id=['Simulink:CodeImporterUI:Question_',id_str];
            obj.Hint_Message_Id=['Simulink:CodeImporterUI:QuestionHint_',id_str];
            obj.Env=env;
            obj.Topic=topic;

            env.registerQuestion(obj);
        end
        function onChange(obj)
            for i=1:length(obj.Options)
                obj.Options{i}.onChange();
            end
        end


        function preShow(obj)
            for i=1:length(obj.Options)
                obj.Options{i}.preShow();
            end
        end

        function out=getQuestionMessage(obj)
            if isempty(obj.QuestionMessage)
                param=obj.MsgParam;
                if~isempty(param)
                    obj.QuestionMessage=message(obj.Question_Message_Id,param{:}).getString;
                else
                    obj.QuestionMessage=message(obj.Question_Message_Id).getString;
                end
            end
            out=obj.QuestionMessage;
        end
        function out=getHintMessage(obj)
            if isempty(obj.HintMessage)
                if obj.HasHintMessage
                    obj.HintMessage=message(obj.Hint_Message_Id).getString;
                else
                    obj.HintMessage='';
                end
            end
            out=obj.HintMessage;
        end

        function out=getSummaryMessage(obj)
            msg_id=['Simulink:CodeImporterUI:QuestionSummary_',obj.Id];
            if obj.HasSummaryMessage
                out=message(msg_id).getString;
            else
                out='';
            end
        end

        function out=constructErrorText(~,msg1,msg2)
            out=['<div style="position:relative; left:40px; top:40px">'...
            ,'<div style="color:red"><b>',msg1,'</b></div>'...
            ,'<div>',msg2,'</div>'...
            ,'</div>'];
        end

        function out=getOptions(obj)
            placeHolder=cell(size(obj.Options));
            out=struct('Message',placeHolder,...
            'HintMessage',placeHolder,...
            'Type',placeHolder,...
            'Value',placeHolder,...
            'Name',placeHolder,...
            'Indent',placeHolder,...
            'Answer',placeHolder,...
            'Enabled',placeHolder,...
            'Hidden',placeHolder);
            for i=1:length(obj.Options)
                out(i).Message=obj.Options{i}.getOptionMessage();
                out(i).HintMessage=obj.Options{i}.getOptionHintMessage();
                out(i).Type=obj.Options{i}.Type;
                out(i).Value=obj.Options{i}.Value;
                out(i).Name=obj.Options{i}.Id;
                out(i).Indent=obj.Options{i}.Indent;
                out(i).Answer=obj.Env.getOptionAnswer(obj.Options{i}.Id);
                out(i).Enabled=obj.Options{i}.isEnabled;
                out(i).Hidden=obj.Options{i}.isHidden;
            end
        end
        function getAndAddOption(obj,env,tag)
            o=env.getOptionObj(tag);
            if isempty(o)
                o=internal.CodeImporterUI.option.(tag)(env);
            end
            for i=1:length(obj.Options)
                if strcmp(obj.Options{i}.Id,tag)

                    return;
                end
            end

            if isempty(o.getNextQuestionId())
                o.setNextQuestionId(obj.NextQuestionId);
            end
            obj.Options{end+1}=o;
        end
        function out=getNextQuestion(obj)
            out=[];
            q_id=obj.NextQuestionId;
            if isempty(q_id)
                for i=1:length(obj.Options)
                    o=obj.Options{i};

                    if o.isEnabled&&o.isAnswered

                        if strcmp(o.Type,'radio')&&o.Answer
                            q_id=o.getNextQuestionId;
                            break;
                        end

                        if strcmp(o.Type,'checkbox')||strcmp(o.Type,'combobox')...
                            ||strcmp(o.Type,'hidden')||strcmp(o.Type,'button')...
                            ||strcmp(o.Type,'user_input')||strcmp(o.Type,'checklist_table')...
                            ||strcmp(o.Type,'radiolist_table')||...
                            strcmp(o.Type,'path')||...
                            strcmp(o.Type,'paths')||...
                            strcmp(o.Type,'file')||...
                            strcmp(o.Type,'files')

                            q_id=o.getNextQuestionId;
                        end
                    end
                end
            end
            if~isempty(q_id)
                out=obj.Env.getQuestionObj(q_id);
            end
        end
        function out=PreviousQuestion(obj)
            out=[];
            if~isempty(obj.PreviousQuestionId)
                out=obj.Env.getQuestionObj(obj.PreviousQuestionId);
            end
        end
        function out=NextQuestion(obj)
            out=[];
            if~isempty(obj.NextQuestionId)
                out=obj.Env.getQuestionObj(obj.NextQuestionId);
            end
        end

        function out=getPostCompileAction(obj)
            out={};
            for i=1:length(obj.Options)
                out=[out,obj.Options{i}.getPostCompileAction];%#ok
            end
        end
        function refresh_question=applyOnChange(obj)
            refresh_question=true;
            obj.onChange();
        end

        function onNext(obj)
            for i=1:length(obj.Options)
                obj.Options{i}.applyOnNext();
            end
        end
        function onPostCompile(obj)
            for i=1:length(obj.Options)
                obj.Options{i}.applyOnPostCompile();
            end
        end
        function out=getSummary(obj)
            out=obj.getSummaryMessage;
            for i=1:length(obj.Options)
                tmp=obj.Options{i}.getSummary;
                if~isempty(tmp)
                    out=[out,': ',tmp];%#ok
                end
            end
        end
        function out=getOptionObj(obj,id)
            out=[];
            options=obj.Options;
            for i=1:length(options)
                if strcmp(obj.Options{i}.Id,id)
                    out=obj.Options{i};
                    return;
                end
            end
        end
        function setDefaultValue(obj,option_id,value)
            env=obj.Env;

            obj.getAndAddOption(env,option_id);
            o=env.getOptionObj(option_id);
            o.Answer=value;
        end
    end
end


