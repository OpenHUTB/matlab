

classdef ResourceBill<hdlcoder.report.ReportPage
    methods
        function obj=ResourceBill(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:RsrUtilTitle',obj.ModelName);
        end

        function generate(obj)
            bom_file=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateBillOfMaterials(bom_file,...
            obj.getTitle,...
            obj.ModelName,...
            obj.PIR,...
            obj.TcgInventory,...
            obj.JavaScriptBody);
        end
        function out=getId(~)
            out='rtwIdBillOfMaterials';
        end
        function out=getDefaultReportFileName(~)
            out='bill_of_materials.html';
        end
    end
end
