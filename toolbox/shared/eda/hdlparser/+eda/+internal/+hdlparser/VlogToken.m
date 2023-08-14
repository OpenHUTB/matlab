


classdef VlogToken


    enumeration
        TAG_UNKNOWN,
        TAG_INPUT,
        TAG_OUTPUT,
        TAG_INOUT,
        TAG_ID,
        TAG_NUMBER,
        TAG_NET,
        TAG_LPAREN,
        TAG_RPAREN,
        TAG_COLON,
        TAG_SEMICOLON,
        TAG_COMMA,
        TAG_SIGNED,
        TAG_LBRK,
        TAG_RBRK,
        TAG_REG,
        TAG_EQ,
        TAG_SHARP;
    end
    methods(Static)
        function tag=getTag(str)
            import eda.internal.hdlparser.VlogToken
            if(isempty(str))
                tag=VlogToken.TAG_UNKNOWN;
                return;
            end

            switch(str)
            case 'input'
                tag=VlogToken.TAG_INPUT;
            case 'output'
                tag=VlogToken.TAG_OUTPUT;
            case 'inout'
                tag=VlogToken.TAG_INOUT;
            case 'reg'
                tag=VlogToken.TAG_REG;
            case{'supply0','supply1','tri','triand','trior','tri0','tri1','wire','wand','wor'}
                tag=VlogToken.TAG_NET;
            case ':'
                tag=VlogToken.TAG_COLON;
            case ';'
                tag=VlogToken.TAG_SEMICOLON;
            case '('
                tag=VlogToken.TAG_LPAREN;
            case ')'
                tag=VlogToken.TAG_RPAREN;
            case ','
                tag=VlogToken.TAG_COMMA;
            case 'signed'
                tag=VlogToken.TAG_SIGNED;
            case '['
                tag=VlogToken.TAG_LBRK;
            case ']'
                tag=VlogToken.TAG_RBRK;
            case '='
                tag=VlogToken.TAG_EQ;
            case '#'
                tag=VlogToken.TAG_SHARP;
            otherwise
                if((str(1)>='0'&&str(1)<='9')||str(1)=='+'||str(1)=='-')
                    tag=VlogToken.TAG_NUMBER;
                else
                    tag=VlogToken.TAG_ID;
                end
            end

        end
        function str=tag2str(tag)
            import eda.internal.hdlparser.VlogToken
            switch(tag)
            case VlogToken.TAG_INPUT
                str='input';
            case VlogToken.TAG_OUTPUT
                str='output';
            case VlogToken.TAG_INOUT
                str='inout';
            case VlogToken.TAG_ID
                str='IDENTIFIER';
            case VlogToken.TAG_NUMBER
                str='NUMBER';
            case VlogToken.TAG_NET
                str='NET';
            case VlogToken.TAG_LPAREN
                str='(';
            case VlogToken.TAG_RPAREN
                str=')';
            case VlogToken.TAG_COLON
                str=':';
            case VlogToken.TAG_SEMICOLON
                str=';';
            case VlogToken.TAG_COMMA
                str=',';
            case VlogToken.TAG_SIGNED
                str='SIGNED';
            case VlogToken.TAG_LBRK
                str='[';
            case VlogToken.TAG_RBRK
                str=']';
            case VlogToken.TAG_REG
                str='REG';
            case VlogToken.TAG_EQ
                str='=';
            case VlogToken.TAG_SHARP
                str='#';
            otherwise
                str='unknown';
            end
        end
    end
end

