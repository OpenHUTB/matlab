classdef DefaultVisitor<internal.TranslationHandler&handle





    methods


        function result=handleAssignment(~,~,~)
            result=[];
        end


        function handleBraceIndexOperation(~,~,~)


            error('shared_adlib:static:UnsupportedConstruct',...
            'Brace indexing not supported by static analysis');
        end


        function result=handleColonIndex(~)
            result=[];
        end


        function result=handleConstant(~,~)
            result=[];
        end

        function result=handleDefineConstant(~,~)
            result=[];
        end


        function result=handleDefineInputVariable(~,~)
            result=[];
        end


        function result=handleDefineOutputVariable(~,~,~)
            result=[];
        end



        function result=handleDefineVariable(~,~)
            result=[];
        end


        function handleDotOperation(~,~,~)


            error('shared_adlib:static:UnsupportedConstruct',...
            'Dot indexing not supported by static analysis');
        end


        function result=handleEndIndex(~)
            result=[];
        end








        function handleExpressionStatement(~,~,~)


            error('shared_adlib:static:UnsupportedConstruct',...
            'Expression statements not supported by static analysis');
        end



        function result=handleForLoop(visitor,~,~,evalLoopBody)

            evalLoopBody(visitor);
            result=[];
        end


        function result=handleFunctionCall(~,~,varargin)
            result=[];
        end


        function handleIfStatement(~,~,~,~,~)
            error('shared_adlib:static:UnsupportedConstruct',...
            'If statements not supported by static analysis');
        end


        function handleIgnored(~)
            error('shared_adlib:static:UnsupportedConstruct',...
            'Ignored outputs not supported by static analysis');
        end



        function result=handleLHSVariable(~,~)
            result=[];
        end



        function result=handleParenIndexOperation(~,~,varargin)
            result=[];
        end



        function printStatement=handlePrintStatement(~,~)

            printStatement=[];
        end


        function result=handleStatements(~,varargin)
            result=[];
        end


        function result=handleVariable(~,~)
            result=[];
        end

    end
end
