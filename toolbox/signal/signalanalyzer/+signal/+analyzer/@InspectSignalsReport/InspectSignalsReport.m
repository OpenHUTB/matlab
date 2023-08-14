classdef InspectSignalsReport<Simulink.sdi.internal.InspectSignalsReport


    methods
        function obj=InspectSignalsReport(sdiEngine)
            obj=obj@Simulink.sdi.internal.InspectSignalsReport(sdiEngine);
        end

    end

    methods(Access=protected)
        function insertTitle(obj)
            import mlreportgen.*;

            titleStr=sprintf('%s%s\t%s',obj.StringDict.MGTitleSigAnalyzer,...
            obj.StringDict.Colon,obj.StringDict.MGInspectSignals);
            section=dom.Group();
            p=dom.Paragraph(titleStr,'Heading1');
            append(section,p);

            obj.insertTimestamp(section);
            obj.addLineBreak(section);

            obj.addNode(section);
        end

    end
end

