function hdlbody=hdlvectorconstantspecialassign(out,zval,type)
































    outname=hdlsignalname(out);
    outsignalsizes=hdlsignalsizes(out);
    [outsize,outbp,outsigned]=deal(outsignalsizes(1),outsignalsizes(2),outsignalsizes(3));
    expanded_out=hdlexpandvectorsignal(out);
    out_iscomplex=hdlsignaliscomplex(out);
    if out_iscomplex
        expanded_out_complex=hdlexpandvectorsignal(hdlsignalimag(out));
    end
    outvec_elem=numel(expanded_out);


    if nargin<2
        zval='z';
    end


    type_choices={'real','complex','all'};
    if nargin<3||isempty(type)||isempty(strmatch(type,type_choices))
        type='all';
    end

    hdlbody='';

    if(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))...
        &&outsize==0
        hdlbody=[hdlbody,'  initial\n    begin\n'];
    end

    if outvec_elem==0
        hdlbody=[hdlbody,scalarconstantz(out,outname,outsize,outbp,...
        outsigned,zval,type)];
    else
        for n=1:outvec_elem
            vectname{1}=hdlsignalname(expanded_out(n));
            if(out_iscomplex)
                vectname{2}=hdlsignalname(expanded_out_complex(n));
            end
            hdlbody=[hdlbody,scalarconstantz(out,vectname,outsize,outbp,...
            outsigned,zval,type)];%#ok<AGROW>
        end

    end

    if(hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog'))...
        &&outsize==0
        hdlbody=[hdlbody,'    end\n'];
    end

    hdlbody=[hdlbody,'\n'];



    function hdlbody=scalarconstantz(out,outname,outsize,~,~,zval,type)

        [assign_prefix,assign_op]=hdlassignforoutput(out);
        complexity=hdlsignaliscomplex(out);

        if outsize==0
            error(message('HDLShared:directemit:realZ'));
        end


        if(~complexity||...
            strcmpi(type,'real')||...
            strcmpi(type,'all'))
            hdlbody=['  ',assign_prefix,outname{1},' ',assign_op,' ',...
            local_hdlconstantvaluez(outsize,zval),...
            ';\n'];
        elseif strcmpi(type,'complex')

            hdlbody=['  ',assign_prefix,outname{2},' ',assign_op,' ',...
            local_hdlconstantvaluez(outsize,zval),...
            ';\n'];
        end

        if complexity&&strcmpi(type,'all')

            hdlbody=[hdlbody...
            ,'  ',assign_prefix,outname{2},' ',assign_op,' ',...
            local_hdlconstantvaluez(outsize,zval),...
            ';\n'];
        end

        function str=local_hdlconstantvaluez(outsize,zval)

            if hdlgetparameter('isvhdl')
                str=['''',upper(zval),''''];
                if outsize~=1
                    str=['(OTHERS => ',str,')'];
                end
            elseif hdlgetparameter('isverilog')||hdlgetparameter('issystemverilog')
                str=sprintf('%d''b%s',outsize,lower(zval));
            else
                error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
            end


