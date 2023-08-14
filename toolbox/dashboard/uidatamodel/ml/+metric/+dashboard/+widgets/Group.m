classdef Group<metric.dashboard.widgets.Container

    properties(Dependent)
Title
    end







    methods


        function set.Title(this,title)
            metric.dashboard.Verify.ScalarCharOrString(title);
            this.MF0Widget.WidgetTitle=title;
        end

        function title=get.Title(this)
            title=this.MF0Widget.WidgetTitle;
        end


        function verify(this)
            if numel(this.Widgets)==0
                error(message('dashboard:uidatamodel:EmptyGroup'));
            end
        end

    end

end
