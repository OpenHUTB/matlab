


classdef CodeGenFail<simulinkcoder.internal.wizard.QuestionBase
    methods
        function obj=CodeGenFail(env)
            id='CodeGenFail';
            topic=message('RTW:wizard:Topic_Finish').getString;
            obj@simulinkcoder.internal.wizard.QuestionBase(id,topic,env);
            obj.getAndAddOption(env,'Finish_ExtraStep');
            obj.HasHelp=false;
            obj.SinglePane=true;
            obj.DisplayRevertButton=true;
            obj.HasHintMessage=false;
            obj.HasSummaryMessage=false;
            obj.HasBack=false;
            obj.CountInProgress=false;
            obj.Topic=message('RTW:wizard:CodeGenFail').getString;
        end
        function out=getQuestionMessage(obj)
            msg1=['<p>',getQuestionMessage@simulinkcoder.internal.wizard.QuestionBase(obj),'</p>'];
            msg2=message('RTW:wizard:Question_CodeGenFail2').getString;
            out=obj.constructErrorText(msg1,msg2);
        end
        function preShow(obj)
            preShow@simulinkcoder.internal.wizard.QuestionBase(obj);
            obj.Env.QuestionTopics={message('RTW:wizard:CodeGenFail').getString};
        end
        function onNext(obj)
            env=obj.Env;
            gui=env.Gui;
            gui.send_command('reset_log');
            gui.send_command('start_spin');
            try

                status=env.generateCode();
            catch e
                gui.send_command('stop_spin');
                gui.send_command('update_log',e.message);
                rethrow(e);
            end
            gui.send_command('stop_spin');
            obj.Options{1}.NextQuestion_Id=simulinkcoder.internal.wizard.question.getNextQuestionIdFinish(status);
        end
    end
end
