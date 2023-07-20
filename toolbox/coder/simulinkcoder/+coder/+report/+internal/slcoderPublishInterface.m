

classdef slcoderPublishInterface<mlreportgen.dom.DocumentPart
    properties
        reportInfo=[];
        dataObj=[]
    end
    methods
        function chapter=slcoderPublishInterface(type,template,obj)
            chapter=chapter@mlreportgen.dom.DocumentPart(type,template);
            chapter.dataObj=obj;
        end
        function fillEntryPointFunctionsTitle(chapter)
            import mlreportgen.dom.*
            text=Text(DAStudio.message('RTW:codeInfo:reportEntryPointFunctions'));
            chapter.append(text);
        end
        function fillEntryPointFunctions(chapter)
            chapter.dataObj.fillEntryPointFunctions(chapter);
        end
        function fillInports(chapter)
            chapter.dataObj.fillInports(chapter);
        end
        function fillOutports(chapter)
            chapter.dataObj.fillOutports(chapter);
        end
        function fillInterfaceParameters(chapter)
            chapter.dataObj.fillInterfaceParameters(chapter);
        end
        function fillDataStores(chapter)
            chapter.dataObj.fillDataStore(chapter);
        end
    end
end
