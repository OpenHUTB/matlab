


classdef LastModified<slxmlcomp.internal.report.fileinfo.FileInfoRetriever

    properties(Access=private)
        DateFormat='dd-mmm-yyyy HH:MM:SS ';
    end

    properties(Access=public)
        Names={slxmlcomp.internal.report.getXMLResourceString('report.info.lastmodified')};
    end

    methods(Access=public)
        function values=getValuesForFile(obj,file)
            jFile=java.io.File(file);
            dateFormat=com.mathworks.toolbox.rptgenxmlcomp.gui.printable.XMLHTMLReportGenerator.getDateFormat();

            values={char(dateFormat.format(java.util.Date(jFile.lastModified())))};
        end
    end

end

