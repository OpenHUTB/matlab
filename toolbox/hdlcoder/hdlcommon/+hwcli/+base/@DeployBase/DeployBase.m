


classdef DeployBase<handle






    properties

RunTaskProgramTargetDevice


ProgrammingMethod

    end





    methods
        function obj=DeployBase()


            obj.RunTaskProgramTargetDevice=true;
            obj.ProgrammingMethod=hdlcoder.ProgrammingMethod.JTAG;

        end
    end





    methods
        function set.RunTaskProgramTargetDevice(obj,val)
            obj.errorCheckTask('RunTaskProgramTargetDevice',val);
            obj.RunTaskProgramTargetDevice=val;
        end

        function set.ProgrammingMethod(obj,val)
            if(~isa(val,'hdlcoder.ProgrammingMethod'))
                error(message('hdlcoder:workflow:InvalidProgrammingMethod'));
            end
            obj.ProgrammingMethod=val;
        end
    end
end


