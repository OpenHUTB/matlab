



classdef Component_Name<dds.internal.ui.app.base.OptionBase

    properties(Hidden,Constant)
        ID='Component_Name';
    end

    methods
        function obj=Component_Name(env)





            id=dds.internal.ui.app.option.Component_Name.ID;
            obj@dds.internal.ui.app.base.OptionBase(id,env);

            obj.OptionMessage=DAStudio.message('dds:toolstrip:uiWizardApplicationName');

            obj.Type='user_input';
            obj.Indent=1;
            obj.Value=env.ComponentName;
            obj.Answer=obj.Value;
        end

        function out=isEnabled(obj)
            out=true;
        end

        function ret=onNext(obj)




            ret=0;
            compName=obj.Value;
            obj.Env.ComponentName=compName;
        end
    end

end


