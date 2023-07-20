


classdef(Sealed)VhdlLexer<eda.internal.hdlparser.HdlLexer


    methods(Access=private)
        function new_id=addMessageID(~,id)
            new_id=['hdlparser:VhdlLexer:',id];
        end
    end
    methods

        function obj=VhdlLexer(HdlText)
            obj.HdlText=HdlText;

            obj.CurrentToken=struct('str','',...
            'tag',eda.internal.hdlparser.VhdlToken.TAG_UNKNOWN,...
            'endindx',0);
            obj.NextToken=obj.CurrentToken;
            obj.isNextTokenValid=false;
        end

        function preProcessing(obj)


            stringLiteral='"[^\n]*?(?<!\\)"';


            obj.HdlText=regexprep(obj.HdlText,stringLiteral,'"STRING_LITERAL"');


            comment='(--.*?\n)';


            obj.HdlText=regexprep(obj.HdlText,comment,'\n');
        end

        function findEntity(obj,entityName)
            entityPattern=['((?<=^\s*)|(?<=;\s*))entity\s+(',entityName,')\s+is\s+'...
            ,'(.*?)'...
            ,'(\s*)end','(\s+entity)?','(\s+',entityName,')?','\s*;'];
            [~,endIndex,tokenIndex]=regexpi(obj.HdlText,entityPattern,'once');
            assert(~isempty(endIndex),obj.addMessageID('EntityNotFound'),...
            sprintf('Could not find declaration for entity "%s"',entityName));

            obj.HdlText(endIndex+1:end)=[];
            obj.CurrentToken.tag=eda.internal.hdlparser.VhdlToken.TAG_ID;
            obj.CurrentToken.str=entityName;
            obj.CurrentToken.endindx=tokenIndex(2,2);
            obj.isNextTokenValid=false;
        end


        function token=peek(obj)



            if(~obj.isNextTokenValid)
                identifier='[a-zA-Z][a-zA-Z0-9_]*';
                decimal_number='([+])?[0-9][0-9_]*';
                pattern=['(',identifier,'|',decimal_number,'|:=|[();,:])'];
                [~,endIndx,~,newToken]=regexpi(obj.HdlText(obj.CurrentToken.endindx+1:end),['(?<=^\s*)',pattern],'once');
                if(~isempty(newToken))
                    obj.NextToken.str=lower(newToken);
                    obj.NextToken.tag=eda.internal.hdlparser.VhdlToken.getTag(obj.NextToken.str);
                    obj.NextToken.endindx=obj.CurrentToken.endindx+endIndx;
                else
                    obj.NextToken.str='';
                    obj.NextToken.tag=eda.internal.hdlparser.VhdlToken.TAG_UNKNOWN;
                    obj.NextToken.endindx=obj.CurrentToken.endindx+1;
                end
                obj.isNextTokenValid=true;
            end
            token=obj.NextToken;
        end





        function skipStaticExpr(obj,numLeftParen)
            if(nargin==1)
                numLeftParen=0;
            end
            pointer=obj.CurrentToken.endindx+1;

            while(pointer<=length(obj.HdlText))
                tmp=obj.HdlText(pointer);
                if(tmp=='(')
                    numLeftParen=numLeftParen+1;
                elseif(tmp==';'||tmp==')')
                    if(numLeftParen<=0)
                        obj.CurrentToken.str='';
                        obj.CurrentToken.tag=eda.internal.hdlparser.VhdlToken.TAG_UNKNOWN;
                        obj.CurrentToken.endindx=pointer-1;
                        obj.NextToken.str=tmp;
                        obj.NextToken.tag=eda.internal.hdlparser.VhdlToken.getTag(tmp);
                        obj.NextToken.endindx=pointer;
                        break;
                    elseif(tmp==')')
                        numLeftParen=numLeftParen-1;
                    end
                end
                pointer=pointer+1;
            end



            assert(pointer<=length(obj.HdlText),...
            obj.addMessageID('ErrorSkippingStaticExpression'),...
            'line %d :cannot find the end of static expression',obj.getLineNumber);
        end





        function genericDeclr=skipGenericDeclr(obj,genericStartIndx)
            numLeftParen=0;
            pointer=obj.CurrentToken.endindx+1;
            r=false;
            genericDeclr='';
            while(pointer<=length(obj.HdlText))
                tmp=obj.HdlText(pointer);
                if(tmp=='(')
                    numLeftParen=numLeftParen+1;
                elseif(tmp==')')
                    if(numLeftParen==0)
                        r=true;
                        obj.CurrentToken.endindx=pointer;
                        genericDeclr=obj.HdlText(genericStartIndx:pointer);
                        obj.CurrentToken.str=genericDeclr;
                        obj.CurrentToken.tag=eda.internal.hdlparser.VhdlToken.TAG_UNKNOWN;
                        obj.isNextTokenValid=false;
                        break;
                    else
                        numLeftParen=numLeftParen-1;
                    end
                end
                pointer=pointer+1;
            end
            assert(r,obj.addMessageID('NoEndGeneric'),...
            'line %d: near "%s", cannot find the end of generic declaration',...
            obj.getLineNumber,obj.CurrentToken.str);
        end

    end


end

