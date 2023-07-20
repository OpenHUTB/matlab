


classdef slcoderPublishSummary<mlreportgen.dom.DocumentPart
    properties
        reportInfo=[];
        dataObj=[]
    end
    methods
        function chapter=slcoderPublishSummary(type,template,obj)
            chapter=chapter@mlreportgen.dom.DocumentPart(type,template);
            chapter.dataObj=obj;
        end
        function fillCoderEnvironment(chapter)
            chapter.dataObj.fillCoderEnvironment(chapter);
        end
        function fillCodeGenAdvisor(chapter)
            chapter.dataObj.fillCodeGenAdvisor(chapter);
        end
    end
end
