classdef parseUtils
    methods(Static=true)
        function isValid=validateBoolean(value)
            isValid=false;
            if isa(value,'char')
                if strcmpi(value,'ON')
                    isValid=true;
                end
                if strcmpi(value,'OFF')
                    isValid=true;
                end
            end

            if isa(value,'logical')
                if value==0
                    isValid=true;
                end
                if value==1
                    isValid=true;
                end
            end
            if(~isValid)
                val=value;
                if isnumeric(value)
                    val=num2str(value);
                end
                msg=message('dnnfpga:workflow:InvalidBooleanParameter',val);
                error(msg);
            end
        end
        function isValid=validateOnOffOrAuto(value)
            isValid=false;
            if isa(value,'char')
                if strcmpi(value,'ON')
                    isValid=true;
                end
                if strcmpi(value,'OFF')
                    isValid=true;
                end
                if strcmpi(value,'AUTO')
                    isValid=true;
                end
            end
            if(~isValid)
                val=value;
                if isnumeric(value)||islogical(value)
                    val=num2str(value);
                end
                msg=message('dnnfpga:workflow:InvalidOnOffAutoParam',val);
                error(msg);
            end
        end
        function bv=toBool(value)
            isValid=false;
            if isa(value,'char')
                if strcmpi(value,'ON')
                    bv=true;
                    isValid=true;
                end
                if strcmpi(value,'OFF')
                    bv=false;
                    isValid=true;
                end
            end
            if isa(value,'logical')
                bv=value~=0;
                isValid=true;
            end
            if(~isValid)
                val=value;
                if isnumeric(value)
                    val=num2str(value);
                end
                msg=message('dnnfpga:workflow:InvalidBooleanParameter',val);
                error(msg);
            end
        end
    end
end

