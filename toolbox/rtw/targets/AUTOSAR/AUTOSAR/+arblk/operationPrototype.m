classdef operationPrototype

    properties
identifier
argument
    end


    methods
        function obj=operationPrototype(modelName,str)
            [fcn,success,err_id,err_msg]=arblk.parseOperationPrototype(str);
            if~success

                error(err_id,err_msg);
            end

            obj.identifier=fcn.name;
            obj.argument=arblk.argumentPrototype.empty(length(fcn.args),0);

            for ii=1:length(fcn.args)
                obj.argument(ii)=arblk.argumentPrototype(modelName,fcn.args(ii).name,fcn.args(ii).dir,fcn.args(ii).dt,fcn.args(ii).dims);
            end

        end


        function obj=set.argument(obj,value)
            if isa(value,'arblk.argumentPrototype')
                obj.argument=value;
            else
                DAStudio.error('RTW:autosar:needArgumentPrototype');
            end
        end


        function args=getINarguments(obj)
            args=obj.argument(strcmp({obj.argument.direction},'IN'));
        end


        function args=getOUTarguments(obj)
            args=obj.argument(strcmp({obj.argument.direction},'OUT'));
        end

    end
end




