

classdef ReportPage<coder.report.ReportPageBase
    properties
ModelName
HDLTraceabilityDriver
PIR
TcgInventory
    end
    methods
        function obj=ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj.ModelName=modelName;
            obj.HDLTraceabilityDriver=HdlTraceabilityDriver;
            obj.PIR=p;
            obj.TcgInventory=tcgInventory;
        end

        function out=getTitle(obj)
            out=['Code Generation Report for ',obj.ModelName];%#ok<I18N_Concatenated_Msg>
        end

        function out=generateErrorReportPage(obj,exception)%#ok<INUSD>
            msg=[getTitle,' is not generated due to an internal error.'];
            bodyOption=['ONLOAD="',coder.internal.coderReport('getOnloadJS',obj.getId()),'"'];
            out=coder.report.ReportPageBase.getDefaultErrorHTML(obj.getTitle,msg,bodyOption);
        end
    end
    methods(Abstract=true)
        getId(~)
    end
end


