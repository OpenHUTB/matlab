classdef(Abstract)LadderInstruction<plccore.common.POU




    methods
        function obj=LadderInstruction(name,desc,input_scope,output_scope,local_scope)
            obj@plccore.common.POU(name,input_scope,output_scope,[],local_scope);
            obj.Kind='LadderInstruction';
            obj.Description=desc;
        end

        function ret=name(obj)
            ret=obj.Name;
        end

        function ret=toString(obj)
            ret=sprintf('%s',obj.name);
        end
    end
end


