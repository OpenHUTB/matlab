


classdef MD5Checksum<slxmlcomp.internal.report.fileinfo.FileInfoRetriever

    properties(Access=public)
        Names={slxmlcomp.internal.report.getXMLResourceString('report.info.checksum')};
    end

    methods(Access=public)
        function values=getValuesForFile(~,file)
            values={lower(Simulink.getFileChecksum(file))};
        end
    end

end

