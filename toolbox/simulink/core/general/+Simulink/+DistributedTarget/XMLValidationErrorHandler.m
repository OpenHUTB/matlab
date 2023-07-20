classdef XMLValidationErrorHandler<matlab.io.xml.dom.ParseErrorHandler




    properties
Errors
    end
    methods
        function cont=handleError(obj,error)

            import matlab.io.xml.dom.*


            idx=numel(obj.Errors)+1;


            obj.Errors(idx).Message=error.Message;


            loc=getLocation(error);
            obj.Errors(idx).Location.LineNumber=loc.LineNumber;
            obj.Errors(idx).Location.ColumnNumber=loc.ColumnNumber;

            cont=true;
        end

        function errs=getErrors(obj)
            errs=obj.Errors;
        end
    end
end
