



classdef(Hidden=true)TlcCodeWriter<rtw.connectivity.CodeWriter


    properties(Constant,Access=private)

        BlockKeywords={'%if','%with','%foreach','%switch','%function'}


        BlockKeywordsMap=containers.Map(...
        legacycode.lct.gen.TlcCodeWriter.BlockKeywords,...
        false(size(legacycode.lct.gen.TlcCodeWriter.BlockKeywords))...
        )
    end


    properties(Access=protected)
        BlockStartString=''
        BlockEndString=''
        CommentStartString='%%'
        CommentEndString=''
        CommentMultiStartString='/%'
        CommentMultiEndString='%/'
        IsLineComment=true
    end


    methods(Hidden)




        function this=TlcCodeWriter(outWriter)
            this@rtw.connectivity.CodeWriter(outWriter);
        end




        function emitBlockStart(this,headStr,endLine,comment)


            emitBlockStart@rtw.connectivity.CodeWriter(this,headStr,false,'');


            if~isempty(comment)
                this.emitComment(comment,false)


                if this.IsLineComment
                    endLine=false;
                end
            end


            if endLine
                this.wNewLine();
            end
        end




        function emitBlockMiddle(this,headStr,endLine)


            oldIndent=this.IndentLevel;
            this.decIndent();
            this.indentOrSpace();


            this.IndentLevel=oldIndent;


            if~isempty(headStr)
                this.raw(headStr);
            end


            if endLine
                this.wNewLine();
            end
        end





        function emitBlockEnd(this,comment,endLine,endTag)%#ok<INUSD>


            startBlockData=this.popBlock();
            this.pushBlock(startBlockData);



            emitBlockEnd@rtw.connectivity.CodeWriter(this,'',false,false);


            if~isempty(startBlockData{1})
                extractedTag=this.getEndTag(startBlockData{1});
                if~isempty(extractedTag)
                    this.emitLine(extractedTag,false,false);
                end
            end


            if~isempty(comment)
                this.emitComment(comment,false);


                if this.IsLineComment
                    endLine=false;
                end
            end


            if endLine
                this.wNewLine();
            end
        end

    end


    methods




        function wFunctionDefStart(this,fcnName,fcnProto)
            startTxt=sprintf('Function: %s ',fcnName);
            numEq=76-numel(startTxt)-numel(this.CommentStartString)-numel(this.SpaceString)-1;
            eqTxt=repmat('=',1,max(0,numEq));
            this.wComment(sprintf('%s%s',startTxt,eqTxt));
            this.wBlockStart(sprintf('%%function %s %s',fcnName,fcnProto));
        end




        function wFunctionDefEnd(this)
            this.wBlockEnd();
            this.wNewLine;
        end




        function wMultilineCommentStart(this,comment)


            if~this.IsFreshLine
                this.wNewLine();
            end


            this.indent();


            this.raw(this.CommentMultiStartString);
            if nargin==2&&~isempty(comment)
                this.wNewLine();
                this.raw([this.SpaceString,comment]);
            end

            this.wNewLine();
        end




        function wMultilineCommentMiddle(this,comment)


            if~this.IsFreshLine
                this.wNewLine();
            end


            this.indent();


            if nargin==2&&~isempty(comment)
                this.raw([this.SpaceString,comment]);
            end

            this.wNewLine();
        end




        function wMultilineCommentEnd(this,comment)


            if~this.IsFreshLine
                this.wNewLine();
            end


            this.indent();


            if nargin==2&&~isempty(comment)
                this.raw([this.SpaceString,comment]);
                this.wNewLine();
            end
            this.raw(this.CommentMultiEndString);

            this.wNewLine();
        end

    end


    methods(Access=protected)





        function endTag=getEndTag(~,startBlockComment)
            endTag=regexprep(startBlockComment,'^(%[\w]*).*$','$1');
            if~isKey(legacycode.lct.gen.TlcCodeWriter.BlockKeywordsMap,endTag)
                endTag='';
            else
                endTag=['%end',endTag(2:end)];
            end
        end

    end

end
