



classdef OptionBase<handle

    properties
        Id=''
        QuestionId=''
        NextQuestionId=''
Type
Value
        Answer=-1
Env
    end
    properties(Access=protected)
        Indent=0
        DepInfo=''
        OptionMessage=''
        HintMessage=''
    end
    methods
        function obj=OptionBase(id,env)





            obj.Id=id;
            obj.Env=env;

            env.registerOption(obj);
        end
        function ret=onNext(~)



            ret=0;
        end
        function out=isEnabled(obj)

            out=true;

            for i=1:length(obj.DepInfo)
                if((isnumeric(obj.DepInfo(i).Value)||islogical(obj.DepInfo(i).Value))&&(obj.Env.getOptionAnswer(obj.DepInfo(i).Option)~=obj.DepInfo(i).Value))...
                    ||(ischar(obj.DepInfo(i).Value)&&~strcmp(obj.Env.getOptionAnswer(obj.DepInfo(i).Option),obj.DepInfo(i).Value))
                    out=false;
                    return
                end
            end
        end
        function ret=applyOnNext(obj)




            ret=0;

            if(obj.isEnabled)

                if strcmp(obj.Type,'combobox')||(obj.Answer&&...
                    (strcmp(obj.Type,'hidden')||...
                    strcmp(obj.Type,'user_input')||...
                    strcmp(obj.Type,'radio')||...
                    strcmp(obj.Type,'file')||...
                    strcmp(obj.Type,'text')))
                    ret=obj.onNext();
                end
            end
        end
        function setAnswer(obj,value)





            if obj.isEnabled

                if any(strcmp(obj.Type,{'combobox','radio','checkbox'}))
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
        function msg=getHintMessage(obj)
            msg=obj.HintMessage;
        end
        function info=getInformation(obj)
            info.Message=obj.OptionMessage;
            info.HintMessage=obj.getHintMessage;
            info.Type=obj.Type;
            info.Value=obj.Value;
            info.Name=obj.Id;
            info.Indent=obj.Indent;
            info.Answer=obj.Env.getOptionAnswer(obj.Id);
            info.Enabled=obj.isEnabled;
        end
    end
end


