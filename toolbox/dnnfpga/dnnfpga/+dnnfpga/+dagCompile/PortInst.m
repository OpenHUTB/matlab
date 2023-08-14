




classdef PortInst<handle&dnnfpga.dagCompile.AddData&matlab.mixin.Copyable
    properties
        name='';
        nameFull='';
size
component
net
    end
    methods
        function obj=PortInst(name,size,component)
            obj.nameFull=sprintf('%s/%s',component.name,name);
            obj.name=name;
            obj.size=size;
            obj.component=component;
        end
        function v=isDriver(obj)
            v=obj==obj.net.driver;
        end
        function v=isReceiver(obj)
            v=~obj.isDriver();
        end
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
            c_name=obj.component.name;
            sizeStr='';
            if isempty(obj.net)
                sizeStr='None';
            elseif~isempty(obj.net.size)
                sizeStr=num2str(obj.net.size);
            end
            str=sprintf('<PortInst [%s] %s>',sizeStr,obj.nameFull);
        end
    end
end
