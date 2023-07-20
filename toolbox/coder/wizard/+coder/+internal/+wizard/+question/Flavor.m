


classdef Flavor<coder.internal.wizard.QuestionBase
    methods
        function obj=Flavor(env)
            id='Flavor';
            topic=message('RTW:wizard:Topic_Output').getString;
            obj@coder.internal.wizard.QuestionBase(id,topic,env);


            obj.getAndAddOption(env,'Flavor_C');
            obj.getAndAddOption(env,'Flavor_Autosar');
            obj.getAndAddOption(env,'Flavor_CppEnc');
            obj.getAndAddOption(env,'Flavor_Autosar_Adaptive');

            currTarget=env.getParam('TargetLang');
            if Simulink.CodeMapping.isAutosarCompliant(env.ModelHandle)
                if strcmp(currTarget,'C++')
                    obj.setDefaultValue('Flavor_Autosar_Adaptive',true);
                else
                    obj.setDefaultValue('Flavor_Autosar',true);
                end
            else
                if strcmp(currTarget,'C++')
                    obj.setDefaultValue('Flavor_CppEnc',true);
                else
                    obj.setDefaultValue('Flavor_C',true);
                end
            end
        end
        function preShow(obj)
            preShow@coder.internal.wizard.QuestionBase(obj);

            env=obj.Env;
            o=env.getOptionObj('Flavor_Autosar');
            if o.isEnabled
                o.OptionMessage=message(['RTW:wizard:Option_',o.Id]).getString;
            elseif~autosarinstalled()
                o.OptionMessage=[message(['RTW:wizard:Option_',o.Id]).getString...
                ,' (',message('RTW:wizard:Option_Extension_Autosar').getString,')'];
            else
                o.OptionMessage=[message(['RTW:wizard:Option_',o.Id]).getString...
                ,' (',message('RTW:wizard:OnlyAvailableForModel').getString,')'];
            end

            o=env.getOptionObj('Flavor_Autosar_Adaptive');
            if o.isEnabled
                o.OptionMessage=message(['RTW:wizard:Option_',o.Id]).getString;
            elseif~autosarinstalled()
                o.OptionMessage=[message(['RTW:wizard:Option_',o.Id]).getString...
                ,' (',message('RTW:wizard:Option_Extension_Autosar').getString,')'];
            else
                o.OptionMessage=[message(['RTW:wizard:Option_',o.Id]).getString...
                ,' (',message('RTW:wizard:OnlyAvailableForModel').getString,')'];
            end

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
