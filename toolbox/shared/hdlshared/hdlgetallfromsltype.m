function s=hdlgetallfromsltype(sltype,varargin)







    if nargin>1
        if~(strcmpi(varargin{1},'inputport')||strcmpi(varargin{1},'outputport'))
            error(message('HDLShared:directemit:WrongArg'));
        end
        ports=true;
    else
        ports=false;
    end
    [size,bp,signed]=hdlgetsizesfromtype(sltype);

    if strcmpi(sltype,'double')||strcmpi(sltype,'single')
        vtype='real';
    else
        [vtype,sltype]=hdlgettypesfromsizes(size,bp,signed);
    end

    s.size=size;
    s.bp=bp;
    s.signed=signed;
    s.vtype=vtype;
    s.sltype=sltype;
    if ports
        if strcmpi(sltype,'double')||strcmpi(sltype,'single')
            if hdlgetparameter('isverilog')
                s.portvtype='wire [63:0]';
            else
                s.portvtype='real';
            end
            s.portsltype=sltype;
        else
            if strcmpi(varargin{1},'inputport')
                if hdlgetparameter('filter_input_type_std_logic')==1
                    [s.portvtype,s.portsltype]=hdlgetporttypesfromsizes(size,bp,signed);
                else
                    s.portvtype=vtype;
                    s.portsltype=sltype;
                end
            else
                if hdlgetparameter('filter_output_type_std_logic')==1
                    [s.portvtype,s.portsltype]=hdlgetporttypesfromsizes(size,bp,signed);
                else
                    s.portvtype=vtype;
                    s.portsltype=sltype;
                end
            end
        end
    end

