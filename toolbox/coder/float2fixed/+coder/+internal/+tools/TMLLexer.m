







classdef TMLLexer<handle
    properties(SetAccess=protected)
filename
text
tokens
    end

    methods
        function disp(this)
            cellfun(@(x)disp(x),this.tokens)
        end


        function this=TMLLexer(m_filename,m_rawText)
            if(nargin<2)
                m_rawText=false;
            end

            this=this@handle();

            this.filename='<:raw-text:>';
            this.tokens={};

            if(~m_rawText)
                this.filename=m_filename;
                this.text=fileread(m_filename);
            else
                this.text=m_filename;
            end


            this.lex();
        end

        function nLen=length(this)
            nLen=length(this.tokens);
        end

        function mt=empty(this)
            mt=this.length()<1;
        end

        function tTok=next(this)
            assert(~this.empty(),'No more tokens; TMLLexer.tokens is empty')
            tTok=this.tokens{1};
            this.tokens(1)=[];
        end


        function addLexerTokensToHead(this,new_lexer)
            assert(isa(new_lexer,'coder.internal.tools.TMLLexer'))
            this.tokens=[new_lexer.tokens(:);this.tokens(:)];
        end

        function dumpText(this)
            fprintf('%s\n',['Remaining tokens on template file, <a href="matlab:edit(''',this.filename,''')">',this.filename,'</a>, (tokens separator is | symbol)'])
            token_values=cellfun(@(x)x.value,this.tokens,'UniformOutput',false);
            if(size(token_values,1)>1)
                token_values=token_values.';
            end
            disp(strjoin(token_values,'|'));
        end

        function dump(this)
            for itr=1:length(this.tokens)
                fprintf('%d > %s\n',itr,this.tokens{itr}.tostr())
            end
        end
    end

    methods(Access=protected)
        function lex(this)
            [a,b,c,d,e,f,g]=regexp(this.text,'(<%[+-=]?)|(%>)','tokens');%#ok<ASGLU>


            if(length(d)~=length(e))
                error(['Parsing/Scanning Error - TML Template ',this.filename,' was erroneous'])
            end


            z=arrayfun(@(x){},zeros(1,length(e)+length(g)),'UniformOutput',false);
            z(1:2:end)=g;
            z(2:2:end)=e;




            for idx=1:(length(e)+length(g))
                curr_text=z{idx};
                if(mod(idx,2)==1)

                    this.tokens{end+1}=coder.internal.tools.TMLToken(coder.internal.tools.TMLTypes.TEXT,curr_text);
                else

                    this.tokens{end+1}=coder.internal.tools.TMLToken(curr_text);
                end
            end

        end
    end
end
