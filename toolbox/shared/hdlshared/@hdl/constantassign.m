function hdlcode=constantassign(out,cval,format,type,baseindent)
















































    outname=hdlsignalname(out);
    outsignalsizes=hdlsignalsizes(out);
    [outsize,outbp,outsigned]=deal(outsignalsizes(1),outsignalsizes(2),outsignalsizes(3));
    expanded_out=hdlexpandvectorsignal(out);
    out_iscomplex=hdlsignaliscomplex(out);
    expanded_out_complex=[];
    if out_iscomplex
        for n=1:length(expanded_out)
            expanded_out_complex=[expanded_out_complex,hdlsignalimag(expanded_out(n))];
        end
    end
    outvec_elem=numel(expanded_out);


    if nargin<3||isempty(format)
        format=cell(1,outvec_elem);
    end


    type_choices={'real','complex','all'};
    if nargin<4||isempty(type)||isempty(strmatch(type,type_choices))
        type='all';
    end

    if nargin<5||isempty(baseindent)
        baseindent=1;
    end

    if nargin==3&&isscalar(format),
        format=repmat(format,1,outvec_elem);
    end

    if isscalar(cval),
        cval=repmat(cval,1,outvec_elem);
    end


    hdlcode=hdlcodeinit;


    if hdlgetparameter('isverilog')&&outsize==0&&~hdlsequentialcontext
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
        hdl.indent(baseindent),'initial',hdl.newline,...
        hdl.indent(baseindent+1),'begin',hdl.newline];
    end

    if outvec_elem==0
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
        scalarconstant(out,outname,outsize,outbp,...
        outsigned,cval,format,type,baseindent)];
    else
        for n=1:outvec_elem
            vectname{1}=hdlsignalname(expanded_out(n));
            if(out_iscomplex)
                vectname{2}=hdlsignalname(expanded_out_complex(n));
            end
            vectval=cval(n);
            vectformat=format{n};
            hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
            scalarconstant(out,vectname,outsize,outbp,...
            outsigned,vectval,vectformat,type,baseindent)];
        end

    end


    if hdlgetparameter('isverilog')&&outsize==0&&~hdlsequentialcontext
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.indent(baseindent+1),'end',hdl.newline];
    end

    if hdlcode.arch_body_blocks(end)~=hdl.newline
        hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,hdl.newline];
    end




    function hdlbody=scalarconstant(out,outname,outsize,outbp,...
        outsigned,cval,format,type,baseindent)

        [assign_prefix,assign_op]=hdlassignforoutput(out);
        complexity=hdlsignaliscomplex(out);


        if hdlgetparameter('isverilog')&&outsize==0&&~hdlsequentialcontext
            assign_prefix=hdl.indent(2);
            assign_op='=';
        end


        if(~complexity||...
            strcmpi(type,'real')||...
            strcmpi(type,'all'))
            hdlbody=[hdl.indent(baseindent),assign_prefix,outname{1},' ',assign_op,' ',...
            hdlconstantvalue(real(cval),outsize,outbp,outsigned,format),...
            ';',hdl.newline];
        elseif strcmpi(type,'complex')

            outimag=hdlsignalimag(out);

            hdlbody=[hdl.indent(baseindent),assign_prefix,outname{2},' ',assign_op,' ',...
            hdlconstantvalue(real(cval),outsize,outbp,outsigned,format),...
            ';',hdl.newline];
        end

        if complexity&&strcmpi(type,'all')

            outimag=hdlsignalimag(out);

            hdlbody=[hdlbody...
            ,hdl.indent(baseindent),assign_prefix,outname{2},' ',assign_op,' ',...
            hdlconstantvalue(imag(cval),outsize,outbp,outsigned,format),...
            ';',hdl.newline];
        end
