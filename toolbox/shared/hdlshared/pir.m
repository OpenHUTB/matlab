function p=pir(varargin)



















    if nargin>2||...
        ((nargin>=1)&&~ischar(varargin{1})&&~isstring(varargin{1}))
        error(message('HDLShared:hdlshared:invalidpirusage'));
    end

    pir_udd(varargin{:});

    if nargin==0

        p=hdlcoder.pir;
    else
        if(nargin==2)
            arg2validstrings={'codegen','sdc','emlc','testbench'};
            if~((ischar(varargin{2})||isstring(varargin{2}))&&...
                any(contains(arg2validstrings,varargin{2})))
                error(message('HDLShared:hdlshared:invalidpirctxtype'));
            end
        end

        p=hdlcoder.pirctx(varargin{:});
    end


