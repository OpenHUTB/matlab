


classdef slcoderPublishSubsystem<mlreportgen.dom.DocumentPart
    properties
        reportInfo=[];
        dataObj=[]
    end
    methods
        function chapter=slcoderPublishSubsystem(type,template,obj)
            chapter=chapter@mlreportgen.dom.DocumentPart(type,template);
            chapter.dataObj=obj;
        end

        function fillCodeMapping(chapter)
            chapter.dataObj.fillCodeMapping(chapter);
        end
        function fillCodeReuseExceptions(chapter)
            chapter.dataObj.fillCodeReuseExceptions(chapter);
        end
    end
end
