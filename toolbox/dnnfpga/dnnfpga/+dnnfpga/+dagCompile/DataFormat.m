








classdef DataFormat<uint8

    enumeration
        None(0)
        FC(1)
        Conv(2)
        FCDirect(3)
    end

    methods
        function disp(obj)
            obj.display();
        end
        function display(obj)
            if numel(obj)==1
                one=obj(1);
                fprintf('%s\n',one.toString());
            else
                fprintf('[');
                for i=1:numel(obj)
                    one=obj(i);
                    fprintf('%s ',one.toString());
                end
                fprintf(']\n');
            end
        end
        function str=toString(obj)
            str=sprintf('<DataFormat %s>',obj);
        end

        function valid=isSameDataFormat(obj,dataFormat)

            valid=obj==dataFormat;
        end

    end

end
