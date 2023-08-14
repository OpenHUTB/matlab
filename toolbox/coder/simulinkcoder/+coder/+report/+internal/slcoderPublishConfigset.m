


classdef slcoderPublishConfigset<mlreportgen.dom.DocumentPart
    properties
        reportInfo=[];
    end
    methods
        function obj=slcoderPublishConfigset(type,template,aReportInfo)
            obj=obj@mlreportgen.dom.DocumentPart(type,template);
            obj.reportInfo=aReportInfo;
        end
        function fillConfigurationParametersTable(obj)
            filepath=obj.reportInfo.getPage('Summary').BInfoMat;
            if exist(filepath,'file')


                load(filepath);
                if isa(infoStructConfigSet,'Simulink.ConfigSet')
                    ConfigSetObj=infoStructConfigSet;
                    ConfigSetObj.readonly='on';
                end
            end
        end
    end
end


