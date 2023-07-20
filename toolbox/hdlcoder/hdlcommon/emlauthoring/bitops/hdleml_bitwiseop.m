%#codegen
function y=hdleml_bitwiseop(mode,varargin)


    coder.allowpcode('plain')
    eml_prefer_const(mode);

    if mode==1
        eml_assert(nargin==2,'bitwise operation ''NOT'' only accept one input');

        y=bitcmp(varargin{1});

    else
        eml_assert(nargin==3,'bitwise operation only accept two input');
        t1=varargin{1};
        t2=varargin{2};

        switch mode
        case 2

            y=bitand(t1,t2);
        case 3

            y=bitor(t1,t2);
        case 4

            y=bitcmp(bitand(t1,t2));
        case 5

            y=bitcmp(bitor(t1,t2));
        case 6

            y=bitxor(t1,t2);
        otherwise
            eml_assert(0,'unsupported bitwise operation');
        end
    end
