


classdef Flavor<simulinkcoder.internal.wizard.QuestionBase
    methods
        function obj=Flavor(env)
            id='Flavor';
            topic=message('RTW:wizard:Topic_Output').getString;
            obj@simulinkcoder.internal.wizard.QuestionBase(id,topic,env);


            obj.getAndAddOption(env,'Flavor_C');
            obj.getAndAddOption(env,'Flavor_CppEnc');

            currTarget=env.getParam('TargetLang');
            if strcmp(currTarget,'C++')
                obj.setDefaultValue('Flavor_CppEnc',true);
            else
                obj.setDefaultValue('Flavor_C',true);
            end

        end
        function preShow(obj)
            preShow@simulinkcoder.internal.wizard.QuestionBase(obj);

            env=obj.Env;
            o=env.getOptionObj('Flavor_CppEnc');
            if o.isEnabled
                o.OptionMessage=message(['RTW:wizard:Option_',o.Id]).getString;
            else
                o.OptionMessage=[message(['RTW:wizard:Option_',o.Id]).getString...
                ,' (',message('RTW:wizard:OnlyAvailableForNonStateflow').getString,')'];
            end
        end
    end
end
