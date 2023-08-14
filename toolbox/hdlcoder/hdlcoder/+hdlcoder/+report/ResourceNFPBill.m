

classdef ResourceNFPBill<hdlcoder.report.ReportPage
    methods
        function obj=ResourceNFPBill(modelName,HdlTraceabilityDriver,p,tcgInventory)
            obj=obj@hdlcoder.report.ReportPage(modelName,HdlTraceabilityDriver,p,tcgInventory);
        end

        function out=getTitle(obj)
            out=DAStudio.message('hdlcoder:report:RsrUtilNfpTitle',obj.ModelName);
        end

        function generate(obj)
            bom_file=fullfile(obj.ReportFolder,obj.getReportFileName);
            obj.HDLTraceabilityDriver.generateNfpBillOfMaterials(bom_file,...
            obj.getTitle,...
            obj.ModelName,...
            obj.PIR,...
            obj.TcgInventory,...
            obj.JavaScriptBody);
        end
        function out=getId(~)
            out='rtwIdNfpBillOfMaterials';
        end
        function out=getDefaultReportFileName(~)
            out='nfp_bill_of_materials.html';
        end
    end
end
