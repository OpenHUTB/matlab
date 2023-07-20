


classdef Optimization<coder.internal.wizard.QuestionBase
    methods
        function obj=Optimization(env)
            id='Optimization';
            topic=message('RTW:wizard:Topic_Optimization').getString;
            obj@coder.internal.wizard.QuestionBase(id,topic,env);

            obj.getAndAddOption(env,'Optimization_Execution');
            obj.getAndAddOption(env,'Optimization_RAM');
            obj.setDefaultValue('Optimization_Execution',true);
            obj.HintMessage=[...
            message(obj.Hint_Message_Id).getString,'<p> </p><div class="warning">'...
            ,env.Gui.getLightBulbImage,' '...
            ,message('RTW:wizard:WarnMoreOptimization').getString,'</div>'];
        end
    end
end


