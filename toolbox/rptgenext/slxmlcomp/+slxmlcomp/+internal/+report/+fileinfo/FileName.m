


classdef FileName<slxmlcomp.internal.report.fileinfo.FileInfoRetriever

    properties(Access=public)
        Names={slxmlcomp.internal.report.getXMLResourceString('report.info.filename')};
    end

    methods(Access=public)
        function values=getValuesForFile(~,file)
            [~,name,~]=fileparts(file);
            values={name};
        end
    end

end

