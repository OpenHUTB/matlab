
classdef Optimization<simulinkcoder.internal.wizard.QuestionBase
    methods
        function obj=Optimization(env)
            id='Optimization';
            topic=message('RTW:wizard:Topic_Optimization').getString;
            obj@simulinkcoder.internal.wizard.QuestionBase(id,topic,env);

            obj.getAndAddOption(env,'Optimization_Debugging');
            obj.getAndAddOption(env,'Optimization_Execution');
            if env.featureEnablePreserveData
                obj.getAndAddOption(env,'PreserveData');
                obj.getAndAddOption(env,'PreserveSignal');
                obj.getAndAddOption(env,'PreserveParameter');
            end
            obj.setDefaultValue('Optimization_Debugging',true);
            obj.HintMessage=[...
            message(obj.Hint_Message_Id).getString,'<p> </p><div class="warning">'...
            ,env.Gui.getLightBulbImage,' '...
            ,message('RTW:wizard:WarnMoreOptimization').getString,'</div>'];
        end
    end
end
