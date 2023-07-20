
classdef WidgetReportBase<handle

    properties
Report
Widget
    end

    methods
        function obj=WidgetReportBase(report,widget)
            obj.Report=report;
            obj.Widget=widget;
        end

        function text=fillHoles(~,text,data)
            fn=fieldnames(data);
            for i=1:numel(fn)
                text=strrep(text,sprintf('{%s}',fn{i}),data.(fn{i}));
            end
        end

        function res=hasHole(~,text,hole)
            res=contains(text,sprintf('{%s}',hole));
        end
    end

    methods(Abstract)
        addToReport(this,parent,scopeArtifact)
    end
end

