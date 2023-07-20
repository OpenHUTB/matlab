classdef DashboardHeader<handle

    properties(Dependent)
        ShowCategoryAggregation;
    end

    properties(Access=private)
MF0Header
    end

    methods(Access=?metric.dashboard.Layout)
        function obj=DashboardHeader(element)
            obj.MF0Header=element;
        end
    end


    methods
        function out=get.ShowCategoryAggregation(this)
            out=this.MF0Header.ShowCategoryAggregation;
        end

        function set.ShowCategoryAggregation(this,val)
            this.MF0Header.ShowCategoryAggregation=val;
        end
    end


end

