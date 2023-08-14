



classdef(Abstract)GuiBase<handle

    properties
        IsAdaptiveWizard=false
QuestionMap
OptionMap
        QuestionTopics={}
        CurrentQuestion=[]
        Debug=false
Gui
Manager
ModelHandle
CompBlkH
CompositionHandle
CloseListener
ArchCloseListener
        IsWizardFinished=false
        ModelClosedOutsideWizard=false
    end

    properties(Transient=true)
LastAnswer
    end

    methods(Abstract,Access=public)
        finish(env)
        start(env)
    end

    methods(Abstract,Access=protected)
        init(env)
    end

    methods(Access=public)
        function registerQuestion(env,q)




            env.QuestionMap(q.Id)=q;
            if~isempty(q.Topic)

                env.QuestionTopics{end+1}=q.Topic;
            end
        end
        function registerOption(env,o)



            env.OptionMap(o.Id)=o;
        end

        function out=getOptionAnswer(env,optionId)



            out=-1;
            if env.OptionMap.isKey(optionId)
                o=env.OptionMap(optionId);
                out=o.Answer;
            end
        end
        function out=getQuestion(env,questionId)



            out=[];
            if env.QuestionMap.isKey(questionId)
                out=env.QuestionMap(questionId);
            end
        end
        function out=getOption(env,optionId)



            out=[];
            if env.OptionMap.isKey(optionId)
                out=env.OptionMap(optionId);
            end
        end

        function moveToPreviousQuestion(env)

            q=env.CurrentQuestion;
            if~isempty(q)

                if~isempty(q.PreviousQuestionId)
                    env.CurrentQuestion=env.QuestionMap(q.PreviousQuestionId);
                end
            end
        end
        function nextQ=moveToNextQuestion(env)


            q=env.CurrentQuestion;
            nextQ=[];
            if~isempty(q)
                nextQ=q.NextQuestion();
                if~isempty(nextQ)
                    q.NextQuestionId=nextQ.Id;


                    if~strcmp(nextQ.Id,q.Id)
                        nextQ.PreviousQuestionId=q.Id;
                    end
                    env.CurrentQuestion=nextQ;
                end
            end
        end

        function ret=onNext(env)

            q=env.CurrentQuestion;
            ret=q.onNext();
        end

        function delete(~)

        end

        function start_spin(env)

            env.Gui.send_command('start_spin');
        end

        function stop_spin(env)

            env.Gui.send_command('stop_spin')
        end

        function CloseForGuiCB(env,eventSrc,~)



            if isequal(env.ModelHandle,eventSrc.Handle)||isequal(env.CompositionHandle,eventSrc.Handle)
                env.ModelClosedOutsideWizard=true;
                env.Gui.cleanup;
            end

        end

    end
end


