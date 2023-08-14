classdef TwoSourceWindowLayout<handle





    properties(Access=private)
        ModelScreenWidthFraction=0.5;
    end


    methods(Access=public,Static)

        function obj=getInstance()
            persistent instance
            if isempty(instance)
                obj=slreq.internal.comparisons.highlight.TwoSourceWindowLayout();
                instance=obj;
            else
                obj=instance;
            end
        end
    end


    methods(Access=public)

        function obj=TwoSourceWindowLayout()
            obj=obj@handle;
        end

        function position=getReportPosition(obj)
            opts=slxmlcomp.options;
            position=opts.PreferredReportPosition;
            if isempty(position)
                position=slreq.internal.comparisons.highlight.getDefaultReportPosition(...
                1-obj.ModelScreenWidthFraction...
                );
            end
        end
    end
end
