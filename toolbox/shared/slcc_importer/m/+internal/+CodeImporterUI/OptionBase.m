classdef OptionBase<handle

    properties
        Id=''
        Property=''
        NextQuestion_Id=''
Type
Value
        Answer=-1
Env
        PostCompileActionCheck={}
        Indent=0
        MsgParam=''
        Question_Id=''
        OptionMessage=''
        HasMessage=true;
        HasHintMessage=true;
        HasSummaryMessage=true;
        HideWidget=false;
        Disabled=false;
        FileFilter={'*.*','All Files (*.*)'}
    end


    methods(Hidden)
        function res=extractProjDefFromUI(~,field)
            res=internal.CodeImporter.tokenize(field);
        end
    end


    methods
        function obj=OptionBase(id_str,env)
            obj.Id=id_str;
            obj.Env=env;

            env.registerOption(obj);
        end


        function initValue(obj)
            if~isempty(obj.Property)
                if isprop(obj.Env.CodeImporter,obj.Property)
                    obj.Value=obj.Env.CodeImporter.(obj.Property);
                end
                if isprop(obj.Env.CodeImporter.CustomCode,obj.Property)
                    obj.Value=obj.Env.CodeImporter.CustomCode.(obj.Property);
                end
                if isprop(obj.Env.CodeImporter.Options,obj.Property)
                    obj.Value=obj.Env.CodeImporter.Options.(obj.Property);
                end
            end
        end


        function onChange(obj)
        end


        function onNext(obj)
        end


        function onPostCompile(~)
        end


        function out=isEnabled(obj)
            out=~obj.Disabled;
        end


        function out=isHidden(obj)
            out=obj.HideWidget;
        end


        function out=getOptionMessage(obj)
            if isempty(obj.OptionMessage)
                if obj.HasMessage
                    param=obj.Env.getOptionParam(obj.Id);
                    msg_id=['Simulink:CodeImporterUI:Option_',obj.Id];
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
                msg_id=['Simulink:CodeImporterUI:OptionSummary_',obj.Id];
                out=message(msg_id).getString;
            else
                out='';
            end
        end


        function out=getOptionHintMessage(obj)
            msg_id=['Simulink:CodeImporterUI:OptionHint_',obj.Id];
            if obj.HasHintMessage
                out=message(msg_id).getString;
            else
                out='';
            end
        end


        function out=getNextQuestionId(obj)
            out=obj.NextQuestion_Id;
        end


        function setNextQuestionId(obj,q_id)
            obj.NextQuestion_Id=q_id;
        end


        function applyOnNext(obj)
            if(~obj.isHidden)
                if strcmp(obj.Type,'radio')||strcmp(obj.Type,'checkbox')

                    obj.onNext();

                elseif strcmp(obj.Type,'combobox')||strcmp(obj.Type,'tree')||...
                    (strcmp(obj.Type,'hidden')&&obj.Answer==true)||...
                    (strcmp(obj.Type,'button')&&obj.Answer==true)||...
                    strcmp(obj.Type,'user_input')||...
                    strcmp(obj.Type,'path')||...
                    strcmp(obj.Type,'paths')||...
                    strcmp(obj.Type,'file')||...
                    strcmp(obj.Type,'files')
                    obj.onNext();
                end
            end
        end


        function applyOnPostCompile(obj)
            if(~obj.isHidden)
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
            if(~obj.isHidden)
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
            if(~obj.isHidden)
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
            if~obj.isHidden
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
                elseif strcmp(obj.Type,'user_input')||strcmp(obj.Type,'file')||...
                    strcmp(obj.Type,'path')||...
                    strcmp(obj.Type,'paths')||...
                    strcmp(obj.Type,'files')
                    reply=value;
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


        function preShow(~)
        end
    end
end