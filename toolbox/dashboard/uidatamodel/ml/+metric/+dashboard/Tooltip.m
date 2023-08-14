classdef Tooltip<handle&dynamicprops

    properties(Access=private)
MF0Tooltips
MF0Model
    end

    methods(Access=?metric.dashboard.widgets.Widget)
        function obj=Tooltip(mf0model,element,locations)
            obj.MF0Tooltips=element;
            obj.MF0Model=mf0model;
            for i=1:numel(locations)
                h=addprop(obj,locations{i});
                h.SetMethod=obj.getSetMethod(locations{i});
                h.GetMethod=obj.getGetMethod(locations{i});
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
                tt=this.MF0Tooltips.getByKey(name);
                if isempty(tt)
                    out='';
                else
                    out=tt.Tooltip;
                end
            end
        end

        function fh=getSetMethod(~,name)
            fh=@set;

            function set(this,val)
                metric.dashboard.Verify.ScalarCharOrString(name);
                if~isempty(this.MF0Tooltips.getByKey(name))
                    this.MF0Tooltips.getByKey(name).destroy();
                end
                tt=dashboard.ui.TooltipContainer(this.MF0Model);
                tt.Location=name;
                tt.Tooltip=val;
                this.MF0Tooltips.add(tt);
            end
        end
    end

end

