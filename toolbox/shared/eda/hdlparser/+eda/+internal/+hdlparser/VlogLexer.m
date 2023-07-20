


classdef(Sealed)VlogLexer<eda.internal.hdlparser.HdlLexer

    methods(Access=private)
        function new_id=addMessageID(~,id)
            new_id=['hdlparser:VlogLexer:',id];
        end
    end
    methods

        function obj=VlogLexer(HdlText)
            obj.HdlText=HdlText;
            obj.isNextTokenValid=false;

            obj.CurrentToken.str='';
            obj.CurrentToken.tag=eda.internal.hdlparser.VlogToken.TAG_UNKNOWN;
            obj.CurrentToken.endindx=0;

            obj.NextToken.str='';
            obj.NextToken.tag=eda.internal.hdlparser.VlogToken.TAG_UNKNOWN;
            obj.NextToken.endindx=0;
        end

        function preProcessing(obj)

            comment1='/\*.*?\*/';
            comment2='//.*?\n';


            stringLiteral='"[^\n]*?(?<!\\)"';


            obj.HdlText=regexprep(obj.HdlText,stringLiteral,'"STRING_LITERAL"');


            [start,finish]=regexp(obj.HdlText,comment1);
            processedHdlText='';
            for m=1:length(start)
                newlines=strfind(obj.HdlText(start(m):finish(m)),char(10));
                if m==1
                    nonComment=obj.HdlText(1:start(1)-1);
                else
                    nonComment=obj.HdlText(finish(m-1)+1:start(m)-1);
                end
                processedHdlText=[processedHdlText,nonComment,char(repmat(10,1,length(newlines)))];%#ok<AGROW>
            end
            if(~isempty(finish))
                obj.HdlText=[processedHdlText,obj.HdlText(finish(end)+1:end)];
            end


            obj.HdlText=regexprep(obj.HdlText,comment2,'\n');
        end

        function findModule(obj,moduleName)







            pattern=['((?<=^\s*)|(?<=;\s*)|(?<=\s+))(?:macro)?module\s+(',moduleName,')(\s|\(|;)'...
            ,'(.*?)'...
            ,'(\s*)endmodule'];

            [~,endIndex,tokenIndex]=regexp(obj.HdlText,pattern,'once');
            assert(~isempty(endIndex),obj.addMessageID('ModuleNotFound'),...
            sprintf('Could not find declaration for module "%s"',moduleName));

            obj.HdlText(endIndex+1:end)=[];
            obj.CurrentToken.endindx=tokenIndex(2,2);
            obj.isNextTokenValid=false;
        end

        function token=peek(obj)
            port_identifier='[a-zA-Z_][a-zA-Z0-9_$]*';
            decimal_number='([+-])?[0-9][0-9_]*';
            pattern=['(',port_identifier,'|',decimal_number,'|[\[\]():;,=#])'];



            if(~obj.isNextTokenValid)
                [~,endIndx,~,newToken]=regexp(obj.HdlText(obj.CurrentToken.endindx+1:end),['(?<=^\s*)',pattern],'once');
                if(~isempty(newToken))
                    obj.NextToken.str=newToken;
                    obj.NextToken.tag=eda.internal.hdlparser.VlogToken.getTag(newToken);
                    obj.NextToken.endindx=obj.CurrentToken.endindx+endIndx;
                else
                    obj.NextToken.str='';
                    obj.NextToken.tag=eda.internal.hdlparser.VlogToken.TAG_UNKNOWN;
                    obj.NextToken.endindx=obj.CurrentToken.endindx+1;
                end
                obj.isNextTokenValid=true;
            end
            token=obj.NextToken;
        end

        function r=scanPortDecl(obj)

            pattern='(\s|;)(input|inout|output)\s';
            [startIndx,~,tokenIndx,~,tokenStr]=regexp(obj.HdlText(obj.CurrentToken.endindx+1:end),pattern,'once');
            if(isempty(startIndx))
                obj.CurrentToken.str='';
                obj.CurrentToken.tag=eda.internal.hdlparser.VlogToken.TAG_UNKNOWN;
                obj.CurrentToken.endindx=length(obj.HdlText);
                obj.NextToken.str='';
                obj.NextToken.tag=eda.internal.hdlparser.VlogToken.TAG_UNKNOWN;
                obj.NextToken.endindx=length(obj.HdlText)+1;
                r=false;
            else
                obj.NextToken.str=tokenStr{2};
                obj.NextToken.tag=eda.internal.hdlparser.VlogToken.getTag(obj.NextToken.str);
                obj.NextToken.endindx=obj.CurrentToken.endindx+tokenIndx(2,2);

                obj.CurrentToken.str='';
                obj.CurrentToken.tag=eda.internal.hdlparser.VlogToken.TAG_UNKNOWN;
                obj.CurrentToken.endindx=obj.CurrentToken.endindx+startIndx;
                r=true;
            end

        end

        function skipRange(obj)
            pointer=obj.CurrentToken.endindx+1;
            while(pointer<=length(obj.HdlText))
                tmp=obj.HdlText(pointer);
                if(tmp==']')
                    obj.CurrentToken.str=']';
                    obj.CurrentToken.tag=eda.internal.hdlparser.VlogToken.getTag(obj.CurrentToken.str);
                    obj.CurrentToken.endindx=pointer;
                    obj.isNextTokenValid=false;
                    break;
                end
                pointer=pointer+1;
            end
        end



        function skipConstantExpr(obj)
            numLeftParen=0;
            pointer=obj.CurrentToken.endindx+1;
            while(pointer<=length(obj.HdlText))
                tmp=obj.HdlText(pointer);
                if(tmp=='(')
                    numLeftParen=numLeftParen+1;
                elseif(numLeftParen<=0&&(tmp==','||tmp==')'||tmp==';'))
                    obj.CurrentToken.tag=eda.internal.hdlparser.VlogToken.TAG_UNKNOWN;
                    obj.CurrentToken.str='';
                    obj.CurrentToken.endindx=pointer-1;
                    obj.isNextTokenValid=false;
                    break;
                elseif(tmp==')')
                    numLeftParen=numLeftParen-1;
                end
                pointer=pointer+1;
            end

            assert(pointer<=length(obj.HdlText),...
            obj.addMessageID('NoEndOfConstantExpression'),'Cannot find the end of constant expression');
        end





        function r=skipParameterDeclr(obj)
            numLeftParen=0;
            pointer=obj.CurrentToken.endindx+1;
            r=false;
            while(pointer<=length(obj.HdlText))
                tmp=obj.HdlText(pointer);
                if(tmp=='(')
                    numLeftParen=numLeftParen+1;
                elseif(tmp==')')
                    if(numLeftParen==0)
                        r=true;
                        obj.CurrentToken.str=')';
                        obj.CurrentToken.tag=eda.internal.hdlparser.VlogToken.getTag(obj.CurrentToken.str);
                        obj.CurrentToken.endindx=pointer;
                        obj.isNextTokenValid=false;
                        break;
                    else
                        numLeftParen=numLeftParen-1;
                    end
                end
                pointer=pointer+1;
            end
        end

    end


end

