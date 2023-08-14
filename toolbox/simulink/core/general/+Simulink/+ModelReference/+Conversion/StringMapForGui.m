




classdef StringMapForGui<handle
    properties(Access=private)
StringMap
    end

    properties(Constant,Access=public)
        Keys={DAStudio.message('Simulink:modelReferenceAdvisor:NormalMode'),...
        DAStudio.message('Simulink:modelReferenceAdvisor:AccelMode'),...
        DAStudio.message('Simulink:modelReference:Software_in_loop_CB')};
        Values={'Normal','Accelerator','Software-in-the-loop (SIL)'};
    end

    methods(Access=public)
        function val=get(this,keyString)
            val=this.Values{strcmp(keyString,this.Keys)};
        end
    end
end
