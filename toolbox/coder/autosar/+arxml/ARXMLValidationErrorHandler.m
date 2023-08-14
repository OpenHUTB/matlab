classdef ARXMLValidationErrorHandler<matlab.io.xml.dom.ParseErrorHandler






    properties
Errors
    end

    methods(Access=public)

        function cont=handleError(this,error)
            import matlab.io.xml.dom.*

            idx=numel(this.Errors)+1;
            this.Errors(idx).Severity=getSeverity(error);
            this.Errors(idx).Message=error.Message;
            loc=getLocation(error);
            this.Errors(idx).Location.FilePath=loc.FilePath;
            this.Errors(idx).LineNumber=loc.LineNumber;
            this.Errors(idx).ColumnNumber=loc.ColumnNumber;
            if severity=="FatalError"

                cont=false;
            else

                cont=true;
            end
        end

        function errMsg=getFormattedErrorMessage(this,inputFile)
            errMsg='';
            numErrors=numel(this.Errors);
            for errIdx=1:numErrors
                curErr=this.Errors(errIdx);
                hyperlinkMsg=sprintf('\n<a href="matlab:autosar.mm.util.MessageReporter.hyperlinkFile(''%s'', %d)">%s:%d</a>\n',...
                inputFile,curErr.LineNumber,inputFile,curErr.LineNumber);

                errMsg=sprintf('%s\n [ line: %d, col:%d ]: %s %s',...
                errMsg,...
                curErr.LineNumber,curErr.ColumnNumber,curErr.Message,hyperlinkMsg);
            end
        end


    end
end
