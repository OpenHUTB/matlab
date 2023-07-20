


classdef slcoderPublishGeneratedCode<mlreportgen.dom.DocumentPart
    properties
        reportInfo=[];
    end
    methods
        function chapter=slcoderPublishGeneratedCode(type,template,aReportInfo)
            chapter=chapter@mlreportgen.dom.DocumentPart(type,template);
            chapter.reportInfo=aReportInfo;
        end

        function fillGeneratedFile(rpt)
            import mlreportgen.dom.*
            files=rpt.reportInfo.getSortedFileInfoList.FileName;
            for i=1:length(files)
                sectionNumber=i;
                subchapter=coder.report.internal.slcoderPublishCodeFile(rpt,files{i},sectionNumber);
                subchapter.fill();
                rpt.append(subchapter);
            end
        end
    end
end
