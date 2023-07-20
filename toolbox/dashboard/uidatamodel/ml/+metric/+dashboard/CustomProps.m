classdef CustomProps<handle&dynamicprops

    properties(Access=private)
MF0CustomProperties
MF0Model
    end

    properties(Constant,Hidden,Abstract)
CustomProperties
    end

    methods(Access=?metric.dashboard.widgets.Widget)
        function obj=CustomProps(mf0Props,mf0Model)
            obj.MF0CustomProperties=mf0Props;
            obj.MF0Model=mf0Model;
            for i=1:numel(obj.CustomProperties)
                h=addprop(obj,obj.CustomProperties{i});
                h.SetMethod=obj.getSetMethod(obj.CustomProperties{i});
                h.GetMethod=obj.getGetMethod(obj.CustomProperties{i});
            end
        end
    end


    methods(Hidden)
        function P=addprop(varargin)
            P=addprop@dynamicprops(varargin{:});
        end
    end

    methods(Access=private)

        function fh=getGetMethod(~,name)
            fh=@get;

            function out=get(this)
                pc=this.MF0CustomProperties.getByKey(name);
                if isempty(pc)
                    out='';
                else
                    out=pc.Value;
                end
            end
        end

        function fh=getSetMethod(~,name)
            fh=@set;

            function set(this,val)
                metric.dashboard.Verify.ScalarCharOrString(name);
                if~isempty(this.MF0CustomProperties.getByKey(name))
                    this.MF0CustomProperties.getByKey(name).destroy();
                end
                pc=dashboard.ui.CustomPropertyContainer(this.MF0Model);
                pc.Name=name;
                pc.Value=val;
                this.MF0CustomProperties.add(pc);
            end
        end
    end

end

