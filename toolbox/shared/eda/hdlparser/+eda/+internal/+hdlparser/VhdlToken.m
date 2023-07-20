


classdef VhdlToken


    enumeration
        TAG_UNKNOWN,
        TAG_IN,
        TAG_OUT,
        TAG_INOUT,
        TAG_LINKAGE,
        TAG_BUFFER,
        TAG_ID,
        TAG_NUMBER,
        TAG_LPAREN,
        TAG_RPAREN,
        TAG_SEMICOLON,
        TAG_COMMA,
        TAG_TO,
        TAG_DOWNTO,
        TAG_COLON,
        TAG_IS,
        TAG_PORT,
        TAG_END,
        TAG_GENERIC,
        TAG_SIGNAL,
        TAG_COLONEQ,
        TAG_BUS;
    end
    methods(Static)




        function tag=getTag(str)
            import eda.internal.hdlparser.VhdlToken
            if(isempty(str))
                tag=VhdlToken.TAG_UNKNOWN;
                return;
            end

            switch(str)
            case 'in'
                tag=VhdlToken.TAG_IN;
            case 'out'
                tag=VhdlToken.TAG_OUT;
            case 'inout'
                tag=VhdlToken.TAG_INOUT;
            case 'linkage'
                tag=VhdlToken.TAG_LINKAGE;
            case 'buffer'
                tag=VhdlToken.TAG_BUFFER;
            case ';'
                tag=VhdlToken.TAG_SEMICOLON;
            case '('
                tag=VhdlToken.TAG_LPAREN;
            case ')'
                tag=VhdlToken.TAG_RPAREN;
            case ','
                tag=VhdlToken.TAG_COMMA;
            case ':'
                tag=VhdlToken.TAG_COLON;
            case 'to'
                tag=VhdlToken.TAG_TO;
            case 'downto'
                tag=VhdlToken.TAG_DOWNTO;
            case 'is'
                tag=VhdlToken.TAG_IS;
            case 'port'
                tag=VhdlToken.TAG_PORT;
            case 'end'
                tag=VhdlToken.TAG_END;
            case 'generic'
                tag=VhdlToken.TAG_GENERIC;
            case 'signal'
                tag=VhdlToken.TAG_SIGNAL;
            case ':='
                tag=VhdlToken.TAG_COLONEQ;
            case 'bus'
                tag=VhdlToken.TAG_BUS;
            otherwise
                if((str(1)>='0'&&str(1)<='9')||str(1)=='+'||str(1)=='-')
                    tag=VhdlToken.TAG_NUMBER;
                else
                    tag=VhdlToken.TAG_ID;
                end
            end
        end
        function str=tag2str(tag)
            import eda.internal.hdlparser.VhdlToken
            switch(tag)
            case VhdlToken.TAG_IN
                str='input';
            case VhdlToken.TAG_OUT
                str='output';
            case VhdlToken.TAG_INOUT
                str='inout';
            case VhdlToken.TAG_LINKAGE
                str='linkage';
            case VhdlToken.TAG_BUFFER
                str='buffer';
            case VhdlToken.TAG_ID
                str='IDENTIFIER';
            case VhdlToken.TAG_NUMBER
                str='NUMBER';
            case VhdlToken.TAG_END
                str='end';
            case VhdlToken.TAG_GENERIC
                str='generic';
            case VhdlToken.TAG_SIGNAL
                str='signal';
            case VhdlToken.TAG_COLONEQ
                str=':=';
            case VhdlToken.TAG_BUS
                str='bus';
            case VhdlToken.TAG_LPAREN
                str='(';
            case VhdlToken.TAG_RPAREN
                str=')';
            case VhdlToken.TAG_COLON
                str=':';
            case VhdlToken.TAG_SEMICOLON
                str=';';
            case VhdlToken.TAG_COMMA
                str=',';
            case VhdlToken.TAG_TO
                str='to';
            case VhdlToken.TAG_DOWNTO
                str='downto';
            case VhdlToken.TAG_IS
                str='is';
            case VhdlToken.TAG_PORT
                str='port';
            otherwise
                str='unknown';
            end
        end
    end
end

