classdef RTMXTableData

    properties(Access=private)
InternalRTMXTableData
    end


    properties(Hidden=true)
        AutoOpenReport=false;
    end


    methods(Hidden=true)
        function obj=RTMXTableData(slrtmxData)
            obj.InternalRTMXTableData=slreq.report.rtmx.utils.SLReqRTMXTableData(slrtmxData);
        end

        function[status,fileName]=exportToHTML(obj,fileName)
            if nargin<2
                fileName='slrtmx.html';
            end

            isOpen=obj.AutoOpenReport;

            [~,~,fileExt]=fileparts(fileName);

            if~strcmpi(fileExt,'.html')
                fileName=[fileName,'.html'];
            end

            try
                obj.InternalRTMXTableData.exportToHTML(fileName);
                fileName=obj.InternalRTMXTableData.HTMLFile;
            catch ex
                status=false;
                fileName=[];
                throwAsCaller(ex);
            end

            status=true;
            if isOpen
                web(obj.InternalRTMXTableData.HTMLFile,'-browser')
            end
        end

        function[status,fileName]=exportToExcel(obj,fileName,sheetName)
            if nargin<3
                sheetName='Matrix';
            end

            if nargin<2
                fileName='slrtmx.xlsx';
            end

            try
                obj.InternalRTMXTableData.exportToExcel(fileName,sheetName);
            catch ex
                status=false;
                fileName=[];
            end
        end
    end
end

