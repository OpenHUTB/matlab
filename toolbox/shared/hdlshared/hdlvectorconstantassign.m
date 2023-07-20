function hdlbody=hdlvectorconstantassign(out,cval,format,type)
















































    outname=hdlsignalname(out);
    outsignalsizes=hdlsignalsizes(out);
    [outsize,outbp,outsigned]=deal(outsignalsizes(1),outsignalsizes(2),outsignalsizes(3));
    expanded_out=hdlexpandvectorsignal(out);
    out_iscomplex=hdlsignaliscomplex(out);
    if out_iscomplex
        expanded_out_complex=hdlexpandvectorsignal(hdlsignalimag(out));
    end
    outvec_elem=numel(expanded_out);


    if nargin<3||isempty(format)
        format=cell(1,outvec_elem);
    end


    type_choices={'real','complex','all'};
    if nargin<4||isempty(type)||isempty(strmatch(type,type_choices))
        type='all';
    end

    if nargin==3&&isscalar(format),
        format=repmat(format,1,outvec_elem);
    end

    if isscalar(cval),
        cval=repmat(cval,1,outvec_elem);
    end


    hdlbody='';

    if hdlgetparameter('isverilog')&&outsize==0
        hdlbody=[hdlbody,'  initial\n    begin\n'];
    end

    if outvec_elem==0
        hdlbody=[hdlbody,scalarconstant(out,outname,outsize,outbp,...
        outsigned,cval,format,type)];
    else
        for n=1:outvec_elem
            vectname{1}=hdlsignalname(expanded_out(n));
            if(out_iscomplex)
                vectname{2}=hdlsignalname(expanded_out_complex(n));
            end
            vectval=cval(n);
            vectformat=format{n};
            hdlbody=[hdlbody,scalarconstant(out,vectname,outsize,outbp,...
            outsigned,vectval,vectformat,type)];
        end

    end

    if hdlgetparameter('isverilog')&&outsize==0
        hdlbody=[hdlbody,'    end\n'];
    end

    hdlbody=[hdlbody,'\n'];



    function hdlbody=scalarconstant(out,outname,outsize,outbp,...
        outsigned,cval,format,type)

        [assign_prefix,assign_op]=hdlassignforoutput(out);
        complexity=hdlsignaliscomplex(out);

        if hdlgetparameter('isverilog')&&outsize==0
            assign_prefix='    ';
            assign_op='=';
        end


        if(~complexity||...
            strcmpi(type,'real')||...
            strcmpi(type,'all'))
            hdlbody=['  ',assign_prefix,outname{1},' ',assign_op,' ',...
            hdlconstantvalue(real(cval),outsize,outbp,outsigned,format),...
            ';\n'];
        elseif strcmpi(type,'complex')

            outimag=hdlsignalimag(out);

            hdlbody=['  ',assign_prefix,outname{2},' ',assign_op,' ',...
            hdlconstantvalue(real(cval),outsize,outbp,outsigned,format),...
            ';\n'];
        end

        if complexity&&strcmpi(type,'all')

            outimag=hdlsignalimag(out);

            hdlbody=[hdlbody...
            ,'  ',assign_prefix,outname{2},' ',assign_op,' ',...
            hdlconstantvalue(imag(cval),outsize,outbp,outsigned,format),...
            ';\n'];
        end
