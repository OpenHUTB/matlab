classdef Parser<handle

    properties

        ExprStr char=''
        FormatString string=""
        Expressions cell={}

    end

    properties(Access=private,Hidden)


BuilderStack
    end

    methods
        function obj=Parser(exprStr)

            import mlreportgen.rpt2api.*
            import mlreportgen.rpt2api.exprstr.*
            import mlreportgen.utils.*
            es=makeSingleLineText(exprStr,newline);
            es=fixGetReported(es);
            obj.ExprStr=char(es);

            obj.Expressions=[];
            obj.BuilderStack=mlreportgen.utils.Stack;
            push(obj.BuilderStack,FormatStringBuilder);
        end

        function parse(obj)

            import mlreportgen.rpt2api.exprstr.*

            if~contains(obj.ExprStr,regexpPattern("%<.*>|%<<.*>>")|newline)
                obj.FormatString=strrep(obj.ExprStr,'"','""');
                return
            end


            nChars=numel(obj.ExprStr);
            i=1;
            while i<=nChars

                switch obj.ExprStr(i)

                case '%'
                    if isStartTag(obj,i)

                        b=top(obj.BuilderStack);
                        b.Str=[b.Str,'%s'];
                        push(obj.BuilderStack,ExpressionBuilder());
                        i=i+2;
                    else
                        if isQuotedStartTag(obj,i)


                            b=top(obj.BuilderStack);
                            b.Str=[b.Str,'%s'];

                            push(obj.BuilderStack,...
                            QuotedExpressionBuilder());
                            i=i+3;
                        end
                    end


                case '>'

                    if isa(obj.BuilderStack.top,...
                        "mlreportgen.rpt2api.exprstr.ExpressionBuilder")
                        builder=pop(obj.BuilderStack);
                        obj.Expressions=[obj.Expressions...
                        ,{builder.Str}];
                        i=i+1;
                    else

                        if isa(obj.BuilderStack.top,...
                            "mlreportgen.rpt2api.exprstr.QuotedExpressionBuilder")
                            k=i+1;
                            if k<=nChars&&obj.ExprStr(k)=='>'
                                builder=pop(obj.BuilderStack);
                                obj.Expressions=[obj.Expressions...
                                ,{builder.Str}];
                                i=i+2;
                            else


                                if i==nChars
                                    error('invalid quoted expression');
                                end
                            end
                        end
                    end
                end




                if i<=nChars
                    builder=obj.BuilderStack.top;
                    build(builder,obj.ExprStr(i));
                    i=i+1;
                end
            end




            builder=pop(obj.BuilderStack);
            obj.FormatString=builder.Str;
        end

        function write(parser,fid,varname)




















            import mlreportgen.rpt2api.exprstr.Parser

            if nargin<3
                varname="rptStr";
            end

            fprintf(fid,"%% Converted from: %s\n",...
            strrep(parser.ExprStr,newline,'\n'));
            if isempty(parser.Expressions)
                if contains(parser.ExprStr,newline)
                    fprintf(fid,'%s = sprintf("%s");\n',varname,...
                    parser.FormatString);
                else
                    fprintf(fid,'%s = "%s";\n',varname,parser.FormatString);
                end
            else
                nExpressions=numel(parser.Expressions);

                if nExpressions==1&&...
                    strcmp(parser.FormatString,'%s')
                    fprintf(fid,'%s = toString(%s);\n',varname,...
                    parser.Expressions{1});
                else
                    for i=1:nExpressions
                        fprintf(fid,'rptEv(%d) = toString(%s);\n',...
                        i,parser.Expressions{i});
                    end
                    fprintf(fid,...
                    '%s = sprintf("%s", rptEv(1:%d));\n',...
                    varname,parser.FormatString,nExpressions);
                end
            end
            fprintf(fid,"\n");

        end

        function tf=isStartTag(obj,i)
            tf=false;
            if numel(obj.ExprStr(i:end))>2
                tag=[obj.ExprStr(i),obj.ExprStr(i+1)];
                tf=strcmp(tag,'%<')&&~strcmp(obj.ExprStr(i+2),'<');
            end
        end

        function tf=isQuotedStartTag(obj,i)
            tf=false;
            if numel(obj.ExprStr(i:end))>3
                tag=[obj.ExprStr(i),obj.ExprStr(i+1),obj.ExprStr(i+1)];
                tf=strcmp(tag,'%<<');
            end
        end
    end

    methods(Static)
        function writeExprStr(fid,exprstr,varname)












            import mlreportgen.rpt2api.exprstr.Parser;

            if nargin<3
                varname="rptStr";
            end

            parser=Parser(exprstr);
            parse(parser);
            write(parser,fid,varname);
        end
    end

end


