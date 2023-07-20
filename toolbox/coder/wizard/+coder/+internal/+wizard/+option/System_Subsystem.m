


classdef System_Subsystem<coder.internal.wizard.OptionBase
    properties
        HasSubsystem=true;
    end
    methods
        function obj=System_Subsystem(env)
            id='System_Subsystem';
            obj@coder.internal.wizard.OptionBase(id,env);
            obj.NextQuestion_Id='Flavor';
            obj.Type='radio';
            obj.Value=false;
            obj.PostCompileActionCheck={'mathworks.codegen.wizard.System_Subsystem'};
            warning_msg=['<span class="warning">'...
            ,env.Gui.getWarningImage,' '...
            ,message('RTW:wizard:SeeWTC').getString,'</span>'];
            obj.OptionMessage=[...
            message(['RTW:wizard:Option_',id]).getString,'&nbsp;&nbsp;&nbsp;&nbsp;',warning_msg];
        end
        function out=isEnabled(obj)
            if obj.HasSubsystem
                out=isEnabled@coder.internal.wizard.OptionBase(obj);
            else
                out=false;
            end
        end
    end
end


