classdef GenericReportType<codergui.ReportType




    properties(Constant)
        ClientTypeValue='generic'
        FileCategory=codergui.ReportType.GENERIC_FILE_CATEGORY
    end

    methods
        function this=GenericReportType()
            this.Priority=double(intmin('int32'));
        end

        function matched=isType(~,~)
            matched=true;
        end

        function title=getWindowTitle(this,~)
            title=this.getDefaultWindowTitle();
        end
    end
end
