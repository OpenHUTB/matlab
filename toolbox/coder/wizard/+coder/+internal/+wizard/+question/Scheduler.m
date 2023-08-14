

classdef Scheduler<coder.internal.wizard.QuestionBase
    methods
        function obj=Scheduler(env)
            id='Scheduler';
            topic=message('RTW:wizard:Topic_Deployment').getString;
            obj@coder.internal.wizard.QuestionBase(id,topic,env);
            obj.regMultiRateOptions;
            obj.setDefaultValue('Scheduler_MultiTask',true);
        end
        function preShow(obj)
            preShow@coder.internal.wizard.QuestionBase(obj);








            env=obj.Env;
            if env.isSubsystemBuild
                sampleTime=env.SubsystemSampleTime;
            else
                sampleTime=env.ModelSampleTime;
            end
            obj.Options={};
            if env.ExportedFunctionCalls
                obj.QuestionMessage=message('RTW:wizard:Question_Scheduler_ExportFunctionCalls').getString;
                obj.Hint_Message_Id='RTW:wizard:QuestionHint_Scheduler_ExportFunctionCalls';
                obj.regSingleRateOptions;
            else
                if strcmp(env.Flavor,'CppEncap')&&env.HasModelReference




                    obj.QuestionMessage=message('RTW:wizard:Question_Scheduler_CppSingleTask').getString;
                    obj.getAndAddOption(env,'Scheduler_SingleTaskCpp');
                    obj.SinglePane=true;
                else
                    obj.SinglePane=false;
                    if sampleTime.SingleRate
                        obj.QuestionMessage=message('RTW:wizard:Question_Scheduler_SingleRate').getString;
                        obj.Hint_Message_Id='RTW:wizard:QuestionHint_Scheduler_SingleRate';
                        obj.regSingleRateOptions;
                    else
                        obj.QuestionMessage=message('RTW:wizard:Question_Scheduler').getString;
                        obj.regMultiRateOptions;
                    end
                end
            end
            if sampleTime.HasAsyncRates
                obj.QuestionMessage=[obj.QuestionMessage,'<br/>',message('RTW:wizard:Question_Scheduler_AsyncRate').getString];
            end
        end
        function regSingleRateOptions(obj)
            env=obj.Env;
            obj.getAndAddOption(env,'Scheduler_SingleRate');
        end
        function regMultiRateOptions(obj)
            env=obj.Env;

            obj.getAndAddOption(env,'Scheduler_MultiTask');
            obj.getAndAddOption(env,'Scheduler_SingleTask');
        end
    end
    methods(Static=true)
        function out=getNextQuestionId(env)
            if slfeature('QuickStartProfile')
                out='MappingProfileCustomization';
            else
                if coder.internal.wizard.isDeviceEditable(env.ModelHandle)
                    out='Wordsize';
                else
                    out='Optimization';
                end
            end
        end
    end
end


