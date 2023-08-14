


classdef FilePath<slxmlcomp.internal.report.fileinfo.FileInfoRetriever

    properties(Access=public)
        Names={slxmlcomp.internal.report.getXMLResourceString('report.info.filepath')};
    end

    methods(Access=public)
        function values=getValuesForFile(~,file)
            [filePath,~,~]=fileparts(file);
            values={filePath};
        end
    end

end

