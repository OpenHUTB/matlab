classdef DocumentPart<mlreportgen.dom.LockedDocumentPart&...
    mlreportgen.report.internal.LockedForm



    methods
        function documentPart=DocumentPart(varargin)
            documentPart@mlreportgen.dom.LockedDocumentPart(varargin{:});
            documentPart@mlreportgen.report.internal.LockedForm();
        end

        function result=open(obj,varargin)
            [key,owner,license]=getOpenArgs(obj,varargin{:});
            result=open@mlreportgen.dom.LockedDocumentPart(obj,key,owner,license);
        end
    end

end

