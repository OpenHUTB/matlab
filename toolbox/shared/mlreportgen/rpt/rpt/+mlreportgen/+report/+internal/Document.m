classdef Document<mlreportgen.dom.LockedDocument&mlreportgen.report.internal.LockedForm




    methods
        function document=Document(varargin)
            document@mlreportgen.dom.LockedDocument(varargin{:});
            document@mlreportgen.report.internal.LockedForm();
        end

        function result=open(obj,varargin)
            [key,owner,license]=getOpenArgs(obj,varargin{:});
            result=open@mlreportgen.dom.LockedDocument(obj,key,owner,license);
        end

    end

end
