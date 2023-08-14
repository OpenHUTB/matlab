


classdef slcoderPublishCodeReplacements<mlreportgen.dom.DocumentPart
    properties
        reportInfo=[];
        dataObj=[]
    end
    methods
        function obj=slcoderPublishCodeReplacements(type,template,codeReplacements)
            obj=obj@mlreportgen.dom.DocumentPart(type,template);
            obj.dataObj=codeReplacements;
        end

        function fillCodeReplacementLibrary(obj)
            obj.dataObj.fillCodeReplacementLibrary(obj);
        end
        function fillCodeReplacementSections(obj)
            obj.dataObj.fillCodeReplacementSections(obj);
        end
    end
end
