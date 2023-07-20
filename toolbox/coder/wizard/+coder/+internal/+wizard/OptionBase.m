


classdef OptionBase<handle

    properties
        Id=''
        NextQuestion_Id=''
Type
Value
        Answer=-1
Env
DepInfo
        PostCompileActionCheck={}
        Indent=0
        MsgParam=''
        Question_Id=''
        OptionMessage=''
        OptionHintMessage=''
        HasMessage=true;
        HasHintMessage=true;
        HasSummaryMessage=true;
    end
    methods
        function obj=OptionBase(id_str,env)
            obj.Id=id_str;
            obj.Env=env;

            env.registerOption(obj);
        end
        function onNext(~)
        end
        function onPostCompile(~)
        end
        function out=isEnabled(obj)
            out=true;
            for i=1:length(obj.DepInfo)
                if((isnumeric(obj.DepInfo(i).Value)||islogical(obj.DepInfo(i).Value))&&(obj.Env.getOptionAnswer(obj.DepInfo(i).Option)~=obj.DepInfo(i).Value))...
                    ||(ischar(obj.DepInfo(i).Value)&&~strcmp(obj.Env.getOptionAnswer(obj.DepInfo(i).Option),obj.DepInfo(i).Value))
                    out=false;
                    return;
                end
            end
        end
        function out=getOptionMessage(obj)
            if isempty(obj.OptionMessage)
                if obj.HasMessage
                    param=obj.Env.getOptionParam(obj.Id);
                    msg_id=['RTW:wizard:Option_',obj.Id];
                    if~isempty(param)
                        obj.OptionMessage=message(msg_id,param{:}).getString;
                    else
                        obj.OptionMessage=message(msg_id).getString;
                    end
                else
                    obj.OptionMessage='';
                end
            end
            out=obj.OptionMessage;
        end
        function out=getSummaryMessage(obj)
            if obj.HasSummaryMessage
                msg_id=['RTW:wizard:OptionSummary_',obj.Id];

                out=message(msg_id).getString;
            else
                out='';
            end
        end
        function out=getOptionHintMessage(obj)
            if isempty(obj.OptionHintMessage)
                msg_id=['RTW:wizard:OptionHint_',obj.Id];
                if obj.HasHintMessage
                    out=message(msg_id).getString;
                else
                    out='';
                end
            else
                out=obj.OptionHintMessage;
            end
        end
        function out=getNextQuestionId(obj)
            out=obj.NextQuestion_Id;
        end
        function applyOnNext(obj)
            if(obj.isEnabled)
                if strcmp(obj.Type,'radio')
                    if obj.Answer==1
                        obj.onNext();
                    end
                elseif strcmp(obj.Type,'checkbox')||strcmp(obj.Type,'combobox')||strcmp(obj.Type,'tree')||...
                    (strcmp(obj.Type,'hidden')&&obj.Answer==true)||...
                    (strcmp(obj.Type,'button')&&obj.Answer==true)
                    obj.onNext();
                end
            end
        end
        function applyOnPostCompile(obj)
            if(obj.isEnabled)
                if strcmp(obj.Type,'radio')||strcmp(obj.Type,'checkbox')
                    if obj.Answer==1
                        obj.onPostCompile();
                    end
                elseif strcmp(obj.Type,'combobox')||strcmp(obj.Type,'hidden')||strcmp(obj.Type,'button')
                    obj.onPostCompile();
                end
            end
        end
        function out=getPostCompileAction(obj)
            out={};
            action=obj.PostCompileActionCheck;
            if(obj.isEnabled)
                if strcmp(obj.Type,'radio')||strcmp(obj.Type,'checkbox')
                    if obj.Answer==1
                        out=action;
                    end
                else
                    out=action;
                end
            end
        end
        function out=getSummary(obj)
            out='';
            if(obj.isEnabled)
                if strcmp(obj.Type,'radio')||strcmp(obj.Type,'checkbox')
                    if obj.Answer==1
                        out=obj.getSummaryMessage;
                    end
                else
                    out=obj.getSummaryMessage;
                end
            end
        end
        function setAnswer(obj,value)
            if obj.isEnabled
                if strcmp(obj.Type,'radio')||strcmp(obj.Type,'checkbox')
                    if ischar(value)
                        reply=str2double(value);
                    else
                        reply=value;
                    end
                elseif strcmp(obj.Type,'combobox')||strcmp(obj.Type,'tree')
                    reply=value;
                elseif strcmp(obj.Type,'hidden')
                    reply=strcmp(value,'true');
                else
                    reply=true;
                end
                obj.Answer=reply;
            end
        end
        function out=isAnswered(obj)
            out=true;
            if isa(obj.Answer,'double')&&obj.Answer==-1
                out=false;
            end
        end
    end
end