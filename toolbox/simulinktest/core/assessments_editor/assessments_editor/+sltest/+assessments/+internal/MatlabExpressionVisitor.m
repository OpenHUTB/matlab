

classdef MatlabExpressionVisitor<handle


    properties(Constant,Access=protected)

        OpMap=containers.Map(...
        {'PLUS','MINUS','MUL','UPLUS','UMINUS','AND','OR','LT','GT','LE','GE','EQ','NE','NOT'},...
        {'+','-','*','+','-','&','|','<','>','<=','>=','==','~=','~'}...
        )
        supportedFunctions={'abs','logical','int8','uint8','int16','uint16','int32','uint32','int64','uint64','single','double','half'};
    end


    properties(SetAccess=protected)
Expr
Tree
Symbols
ReservedSymbols
BuiltinSymbols
AssessmentsCode
SyntaxErrors
SymbolErrors
TypeErrors
ExprHighlight
CommentPos
DataType
DefinedSymbols
DefinedUnresolvedSymbols
SymbolsNamespace
ConvertScalarToConstant
    end


    methods


        function this=MatlabExpressionVisitor(expr,varargin)

            p=inputParser;
            p.PartialMatching=true;

            p.addParameter('DataType','');
            p.addParameter('Symbols',{});
            p.addParameter('UnresolvedSymbols',{});
            p.addParameter('SymbolsNamespace','',@(s)validateattributes(s,{'char','string'},{'scalartext'}));
            p.addParameter('ConvertScalarToConstant',true,@(s)validateattributes(s,{'logical'},{'scalar'}))
            p.parse(varargin{:});
            results=p.Results;
            this.DataType=results.DataType;
            this.DefinedSymbols=results.Symbols;
            this.DefinedUnresolvedSymbols=results.UnresolvedSymbols;
            this.SymbolsNamespace=results.SymbolsNamespace;
            this.ConvertScalarToConstant=results.ConvertScalarToConstant;

            this.Expr=expr;


            symbs=strjoin(results.Symbols,',');


            this.Tree=mtree(['a=',expr],'-com',['-param=',symbs]);
            this.Symbols={};
            this.ReservedSymbols={};
            this.BuiltinSymbols={};
            this.AssessmentsCode='';
            this.SyntaxErrors=[];
            this.SymbolErrors=[];
            this.TypeErrors=[];
            this.ExprHighlight='';
            this.CommentPos=[];



            this.checkIdentifiers();

            this.visit();
            this.checkDataType();
            this.toHtmlExpr();


            if~isempty(this.SyntaxErrors)||~isempty(this.TypeErrors)
                this.Symbols={};
                this.AssessmentsCode='';
            end
        end


        function yesno=hasError(this)
            yesno=~isempty(this.SyntaxErrors)||~isempty(this.TypeErrors)||~isempty(this.SymbolErrors);
        end


        function yesno=isLogicalExpression(this)
            node=this.getExprNode();
            if~isnull(node)
                switch node.kind
                case{'AND','OR','LT','GT','LE','GE','EQ','NE','NOT','ID'}
                    yesno=true;
                case 'CALL'
                    id=string(Left(node));
                    yesno=ismember(id,{'true','false','logical'})||~ismember(id,this.supportedFunctions);
                otherwise
                    yesno=false;
                end
            else
                yesno=false;
            end
        end


        function yesno=isNumericExpression(this)
            node=this.getExprNode();
            if~isnull(node)
                switch node.kind
                case{'AND','OR','LT','GT','LE','GE','EQ','NE','NOT'}
                    yesno=false;
                case{'INT','DOUBLE','ID'}
                    yesno=true;
                case 'CALL'
                    id=string(Left(node));
                    yesno=~ismember(id,{'true','false','logical'});
                otherwise
                    yesno=true;
                end
            else
                yesno=false;
            end
        end


        function yesno=isTimeExpression(this)
            node=this.getExprNode();
            if~isnull(node)
                switch node.kind
                case{'INT','DOUBLE','ID'}
                    yesno=true;
                case 'CALL'
                    id=string(Left(node));
                    yesno=~ismember(id,{'true','false','logical'});
                otherwise
                    yesno=false;
                end
            else
                yesno=false;
            end
        end
    end


    methods(Access=protected)

        function node=getExprNode(this)
            node=root(this.Tree);
            if isnull(node)||isnull(wholetree(node))||~ismember(node.kind,{'PRINT','EXPR'})
                node=null(node);
            else
                node=Arg(node);
                assert(strcmp(node.kind,'EQUALS'));
                node=Right(node);
            end
        end

        function checkIdentifiers(this)
            expression='[a-zA-Z]\w*';
            [match,~]=regexp(this.Expr,expression,'match','split');
            for i=1:length(match)
                if strlength(match(i))>63
                    errMsg=message("sltest:assessments:LongMatlabIdentifier");
                    start_index=strfind(this.Expr,match(i));
                    end_index=start_index+strlength(match(i))-1;
                    this.reportSyntaxError(errMsg,start_index+2,end_index+2);
                end
            end
        end



        function checkDataType(this)
            switch this.DataType
            case 'boolean'
                if(~this.isLogicalExpression)
                    errMsg=message("sltest:assessments:ExpectExpressionOfType",'logical');
                    this.reportTypeError(errMsg,3,strlength(this.Expr)+2);
                end
            case{'signal','numeric'}
                if(~this.isNumericExpression)
                    errMsg=message("sltest:assessments:ExpectExpressionOfType",'numeric');
                    this.reportTypeError(errMsg,3,strlength(this.Expr)+2);
                end
            case{'time'}
                if(~this.isTimeExpression)
                    errMsg=message("sltest:assessments:InvalidTimeExpression");
                    this.reportTypeError(errMsg,3,strlength(this.Expr)+2);
                end
            otherwise
            end
        end


        function toHtmlExpr(this)
            if~isempty(this.SyntaxErrors)

                tempSyntaxErr=struct2table(this.SyntaxErrors);
                [~,i]=unique(tempSyntaxErr.pos(:,1));
                tempSyntaxErr=tempSyntaxErr(i,:);
                this.SyntaxErrors=table2struct(sortrows(tempSyntaxErr,'pos'));
                this.toHtmlErrorExpr('SyntaxErrors');
            else
                if~isempty(this.TypeErrors)
                    this.toHtmlErrorExpr('TypeErrors');
                else
                    if~isempty(this.SymbolErrors)
                        this.toHtmlErrorExpr('SymbolErrors');
                    else
                        if(this.CommentPos>0)
                            beforeComment=extractBefore(this.Expr,this.CommentPos-2);
                            afterComment=extractAfter(this.Expr,this.CommentPos-2);
                            this.ExprHighlight=sprintf('%s<span class="comment-style">%c%s</span>',escapeChar(beforeComment),'%',escapeChar(afterComment));
                        end
                    end
                end
            end
        end


        function toHtmlErrorExpr(this,errorType)
            lastPos=1;
            this.ExprHighlight='';
            switch errorType
            case 'SymbolErrors'
                errorList=this.SymbolErrors;
                errorStyle='symbol-error-style';
            case 'SyntaxErrors'
                errorList=this.SyntaxErrors;
                errorStyle='syntax-error-style';
            case 'TypeErrors'
                errorList=this.TypeErrors;
                errorStyle='type-error-style';
            otherwise
                assert(false);
            end



            for i=1:numel(errorList)
                beforeErr=string(extractBetween(this.Expr,lastPos,errorList(i).pos(1)-1));
                currentErr=string(extractBetween(this.Expr,errorList(i).pos(1),errorList(i).pos(2)));
                lastPos=errorList(i).pos(2)+1;
                this.ExprHighlight=sprintf('%s%s<span title="%s" class="%s">%s</span>',this.ExprHighlight,escapeChar(beforeErr),escapeChar(errorList(i).msg.getString()),errorStyle,escapeChar(currentErr));
            end


            lastBlock=string(extractAfter(this.Expr,lastPos-1));
            splitLast=split(lastBlock,'%');
            if(numel(splitLast)>1)
                escapedLastBlock=sprintf('%s<span class="comment-style">%c%s</span>',escapeChar(splitLast{1}),'%',escapeChar(strjoin(splitLast(2:end))));
            else
                escapedLastBlock=escapeChar(lastBlock);
            end
            this.ExprHighlight=sprintf('%s%s',this.ExprHighlight,escapedLastBlock);
        end


        function reportSyntaxError(this,errMsg,startPos,endPos)
            this.SyntaxErrors(end+1).msg=errMsg;
            this.SyntaxErrors(end).pos=[startPos-2,endPos-2];
        end


        function reportSymbolError(this,errMsg,startPos,endPos)
            this.SymbolErrors(end+1).msg=errMsg;
            this.SymbolErrors(end).pos=[startPos-2,endPos-2];
        end


        function reportTypeError(this,errMsg,startPos,endPos)
            this.TypeErrors(end+1).msg=errMsg;
            this.TypeErrors(end).pos=[startPos-2,endPos-2];
        end


        function yesno=reportErrorIfBuiltin(this,idNode)
            yesno=false;
            id=string(idNode);
            if exist(id,'builtin')==5
                errMsg=message("sltest:assessments:InvalidUseOfBuiltin",id);
                this.reportSyntaxError(errMsg,position(idNode),endposition(idNode));
                yesno=true;
                this.BuiltinSymbols{end+1}=id;
            end
        end


        function addSymbol(this,id,pos)
            this.Symbols{end+1}=id;
            if~ismember(id,this.DefinedSymbols)||ismember(id,this.DefinedUnresolvedSymbols)
                errMsg=message("sltest:assessments:UseOfUnresolvedSymbol",id);
                this.reportSymbolError(errMsg,pos(1),pos(2));
            end
        end


        function value=getDoubleValue(this,node)
            value=str2double(node.string);
            if~isreal(value)
                errMsg=message("sltest:assessments:UnsupportedComplexNumber");
                this.reportSyntaxError(errMsg,position(node),endposition(node));
            end
        end


        function code=getConstantCode(this,valueStr)
            if this.ConvertScalarToConstant
                code=sprintf('sltest.assessments.Constant(%s)',valueStr);
            else
                code=valueStr;
            end
        end



        function visit(this,node)
            if nargin<2
                node=root(this.Tree);

                if(~isnull(Next(node)))
                    nextnode=Next(node);
                    c=position(Next(node));
                    if strcmp(nextnode.kind,'COMMENT')
                        this.CommentPos=c;
                    else
                        errMsg=message("sltest:assessments:NotAValidMatlabExpression");
                        this.reportSyntaxError(errMsg,c,c);
                        return
                    end
                end

                if(ismember(node.kind,{'PRINT','EXPR'}))
                    node=Arg(node);
                    assert(strcmp(node.kind,'EQUALS'));
                    node=Right(node);
                end
            end

            if isnull(node)||isnull(wholetree(node))

                return
            end


            switch node.kind
            case 'ERR'
                this.visitErr(string(node));
            case 'PARENS'
                this.visitParens(Arg(node));
            case 'NOT'
                argNode=Arg(node);
                this.visitUnaryOp(this.OpMap(node.kind),argNode);
            case{'UMINUS'}
                argNode=Arg(node);
                if~isnull(argNode)
                    if strcmp(argNode.kind,'INT')

                        val=sscanf(string(argNode),'%d');
                        val=-val;
                        this.visitInt(val);
                    else
                        if strcmp(argNode.kind,'DOUBLE')

                            val=this.getDoubleValue(argNode);
                            val=-val;
                            this.visitDouble(val);
                        else

                            this.visitUnaryOp(this.OpMap(node.kind),argNode);
                        end
                    end
                else

                    errMsg=message("sltest:assessments:NotAValidMatlabExpression");
                    this.reportSyntaxError(errMsg,position(node),endposition(node));
                end
            case{'UPLUS'}

                argNode=Arg(node);
                if~isnull(argNode)
                    this.visit(argNode);
                else

                    errMsg=message("sltest:assessments:NotAValidMatlabExpression");
                    this.reportSyntaxError(errMsg,position(node),endposition(node));
                end
            case{'MUL','PLUS','MINUS','AND','OR','LT','GT','LE','GE','EQ','NE'}
                this.visitBinaryOp(this.OpMap(node.kind),Left(node),Right(node));
            case 'ID'
                this.visitIdNode(node);
            case 'INT'
                this.visitInt(sscanf(string(node),'%d'));
            case 'DOUBLE'
                this.visitDouble(this.getDoubleValue(node));
            case 'CALL'

                callee=Left(node);
                firstArg=Right(node);

                if isnull(firstArg)


                    this.visit(callee);
                else



                    numArgs=1;
                    args={firstArg};
                    while~isnull(Next(args{end}))
                        numArgs=numArgs+1;
                        args{end+1}=Next(args{end});
                    end
                    this.visitFcnCall(callee,args);
                end
            case 'COMMENT'
                this.CommentPos=position(node);
            case 'HEX'
                errMsg=message("sltest:assessments:HexNotationIsNotSupported");
                this.reportSyntaxError(errMsg,position(node),endposition(node));
            otherwise
                s=position(node);
                e=endposition(node);
                try
                    operatorString=string(node);
                    errMsg=message("sltest:assessments:UnsupportedOperator",operatorString);
                catch
                    operatorString=string(extractBetween(this.Expr,s-2,e-2));
                    errMsg=message("sltest:assessments:UnsupportedOperator",operatorString);
                end
                this.reportSyntaxError(errMsg,s,e);
            end
        end


        function visitErr(this,errString)





            pos=sscanf(errString,'L %d (C %d-%d)');

            if(pos(2)==strlength(this.Expr)+2)


                splitExpr=split(this.Expr,'%');
                if(numel(splitExpr)>1)
                    if isempty(splitExpr{1})

                        this.CommentPos=3;
                        return;
                    end
                    tmp=mtree(['a=',splitExpr{1}]);
                    node=root(tmp);
                    if strcmp(node.kind,'ERR')
                        s=string(node);
                        pos=sscanf(s,'L %d (C %d-%d)');
                        if(numel(pos)<3)
                            pos(3)=pos(2);
                        end
                    else

                        pos=[1,0,strlength(this.Expr)+2];
                    end
                end
            end



            tmp=extractBefore(this.Expr,pos(2)-2);
            splitTmp=split(tmp,{' ','(',','});
            l=1;

            for i=1:numel(splitTmp)
                wL=strlength(splitTmp{i});


                if(iskeyword(splitTmp{i}))
                    errMsg=message("sltest:assessments:InvalidUseOfKeyword",string(splitTmp{i}));
                    this.reportSyntaxError(errMsg,l,l+wL);
                end
                l=l+wL+1;
            end


            errMsg=message("sltest:assessments:NotAValidMatlabExpression");
            if numel(pos)>2
                c=extractBetween(this.Expr,pos(2)-2,pos(3)-2);
                if(iskeyword(c))
                    errMsg=message("sltest:assessments:InvalidUseOfKeyword",string(c));
                end
                this.reportSyntaxError(errMsg,pos(2),pos(3));
            else

                splitErr=split(errString,':');
                switch strtrim(splitErr{2})
                case 'SYNER'

                    errMsg=message("sltest:assessments:NotAValidMatlabExpression");
                case{'EOLPAR','NOPAR'}
                    errMsg=message("sltest:assessments:MissingParenthesis");
                otherwise
                    errMsg=message("sltest:assessments:NotAValidMatlabExpression");
                end
                this.reportSyntaxError(errMsg,pos(2),pos(2));
            end

            this.AssessmentsCode='';
        end


        function visitParens(this,node)
            this.AssessmentsCode=sprintf('%s(',this.AssessmentsCode);
            this.visit(node);
            this.AssessmentsCode=sprintf('%s)',this.AssessmentsCode);
        end


        function visitBinaryOp(this,op,lnode,rnode)
            this.visit(lnode);
            this.AssessmentsCode=sprintf('%s%s',this.AssessmentsCode,op);
            this.visit(rnode);
        end


        function visitUnaryOp(this,op,node)
            this.AssessmentsCode=sprintf('%s%s',this.AssessmentsCode,op);
            this.visit(node);
        end


        function visitInt(this,val)
            this.AssessmentsCode=sprintf('%s%s',this.AssessmentsCode,this.getConstantCode(sprintf('%d',val)));
        end


        function visitDouble(this,val)
            this.AssessmentsCode=sprintf('%s%s',this.AssessmentsCode,this.getConstantCode(sprintf('%g',val)));
        end


        function visitLogical(this,val)
            this.AssessmentsCode=sprintf('%s%s',this.AssessmentsCode,this.getConstantCode(val));
        end


        function visitIdNode(this,idNode)
            id=string(idNode);
            switch id
            case{'true','false'}
                this.visitLogical(id);
            case this.DefinedSymbols
                this.addSymbol(id,[position(idNode),endposition(idNode)]);
                this.AssessmentsCode=sprintf('%s%s%s',this.AssessmentsCode,this.SymbolsNamespace,id);
            case 't'
                if strcmp(stm.internal.assessmentsFeature('useReservedTimeVariable'),'on')
                    this.ReservedSymbols{end+1}=id;
                else
                    this.addSymbol(id,[position(idNode),endposition(idNode)]);
                end
                this.AssessmentsCode=sprintf('%s%s%s',this.AssessmentsCode,this.SymbolsNamespace,id);
            otherwise
                if~this.reportErrorIfBuiltin(idNode)
                    this.addSymbol(id,[position(idNode),endposition(idNode)]);
                    this.AssessmentsCode=sprintf('%s%s%s',this.AssessmentsCode,this.SymbolsNamespace,id);
                end
            end
        end


        function visitFcnCall(this,callee,args)
            funcname=string(callee);
            this.AssessmentsCode=sprintf('%s%s(',this.AssessmentsCode,funcname);
            if~ismember(funcname,this.supportedFunctions)
                if~this.reportErrorIfBuiltin(callee)
                    errMsg=message("sltest:assessments:InvalidFunctionCall",funcname);
                    this.reportSyntaxError(errMsg,position(callee),endposition(callee));
                end
            else
                if numel(args)>1
                    if isnull(Right(args{1}))
                        pos=righttreepos(args{1})+1;
                    else
                        pos=righttreepos(Right(args{1}))+1;
                    end
                    errMsg=message("sltest:assessments:TooManyArguments",funcname,1,numel(args));
                    this.reportSyntaxError(errMsg,pos,endposition(args{end}));
                end
            end

            for i=1:numel(args)
                if(i>1)
                    this.AssessmentsCode=sprintf('%s,',this.AssessmentsCode);
                end
                this.visit(args{i});
            end
            this.AssessmentsCode=sprintf('%s)',this.AssessmentsCode);
        end
    end
end


function r=escapeChar(e)
    r=strrep(e,'&','&amp;');
    r=strrep(r,'>','&gt;');
    r=strrep(r,'<','&lt;');
end

