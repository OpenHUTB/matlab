


classdef HdlLexer<handle


    properties
        HdlText;
        CurrentToken;
        CurrentTokenEndIndx;
        NextToken;
        NextTokenEndIndx;
        isNextTokenValid;
    end

    methods(Abstract=true)
        preProcessing(obj);
        token=peek(obj);
    end
    methods(Access=public)
        function lineNumber=getLineNumber(obj)
            newLine=find(obj.HdlText(1:obj.CurrentToken.endindx)==char(10));
            lineNumber=length(newLine)+1;
        end

        function token=scan(obj)
            obj.CurrentToken=obj.peek;
            obj.isNextTokenValid=false;
            token=obj.CurrentToken;
        end

        function token=getToken(obj)
            token=obj.CurrentToken;
        end
    end
end

