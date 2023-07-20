



classdef QuestionBase<handle
    properties
        Id=''
        Options={}
        PreviousQuestionId=''
        NextQuestionId=''
        Topic=''
        TrailTable=[]
    end



    properties(Access=protected)
        QuestionMessage=''
        HintMessage=''
        DisplayFinishButton=false
        DisplayFixAllButton=false
        HasHelp=true
        HasBack=true
Env
    end
    properties(Abstract)
        HelpViewID;
    end
    methods
        function obj=QuestionBase(id,topic,env)






            obj.Id=id;
            obj.Env=env;
            obj.Topic=topic;

            env.registerQuestion(obj);
        end
        function onChange(~)

        end
        function preShow(~)

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
            'Enabled',placeHolder);


            for i=1:length(obj.Options)
                out(i)=obj.Options{i}.getInformation;
            end
        end
        function getAndAddOption(obj,tag)





            env=obj.Env;
            o=env.getOption(tag);
            if isempty(o)
                o=sl.interface.dict.migrator.option.(tag)(env);
            end

            for i=1:length(obj.Options)
                if strcmp(obj.Options{i}.Id,tag)
                    return
                end
            end

            o.QuestionId=obj.Id;

            obj.Options{end+1}=o;
        end
        function out=PreviousQuestion(obj)

            out=[];
            if~isempty(obj.PreviousQuestionId)
                out=obj.Env.getQuestion(obj.PreviousQuestionId);
            end
        end
        function out=NextQuestion(obj)

            out=[];
            if~isempty(obj.NextQuestionId)
                out=obj.Env.getQuestion(obj.NextQuestionId);
            end
        end
        function refreshQuestion=applyOnChange(obj)

            refreshQuestion=true;
            obj.onChange();
        end
        function ret=onNext(obj)


            ret=0;
            for i=1:length(obj.Options)
                ret=obj.Options{i}.applyOnNext();
                if ret<0
                    return
                end
            end
        end



        function info=getInformation(obj)
            info.msg=strrep(obj.QuestionMessage,newline,'<br/>');
            info.hint=obj.HintMessage;
            info.hasHelp=obj.HasHelp;
            info.hasBack=obj.HasBack;
            info.DisplayFinishButton=obj.DisplayFinishButton;
            info.DisplayFixAllButton=obj.DisplayFixAllButton;
        end

        function updateNextQuestionInfo(obj,nextQuestionId,displayFinishButton)
            obj.NextQuestionId=nextQuestionId;
            obj.DisplayFinishButton=displayFinishButton;
        end

        function value=getOptionValue(obj,optionName)
            answers=obj.Env.LastAnswer.Value;

            answer=answers(cellfun(@(x)isequal(x,optionName),{answers.option}));

            value=answer.value;
        end

        function refreshOnFileSelection(obj,optionName)



            selectedFile=obj.getOptionValue(optionName);

            option=obj.Env.getOption(optionName);
            assert(strcmp(option.Type,'file'),'Expected file selection option');
            [folder,file,ext]=fileparts(selectedFile);
            option.Value.file=[file,ext];
            if~isempty(folder)
                option.Value.folder=[folder,filesep];
            else
                option.Value.folder='';
            end
        end

        function helpViewID=getHelpViewID(obj)
            helpViewID=obj.HelpViewID;
        end
    end

end


