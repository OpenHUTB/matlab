classdef Bundle<metric.dashboard.widgets.Group







    methods
        function verify(this)
            if numel(this.Widgets)==0
                error(message('dashboard:uidatamodel:EmptyBundle'));
            end
        end
    end

end

