function str=conditional_expr(in,sel,selValues,out,muxtype)































    construct_indent=hdl.indent(0);
    choice_indent=hdl.indent(1);
    subchoice_indent=hdl.indent(2);
    subsubchoice_indent=hdl.indent(2);

    maxSelValue=ceil(log2(max(length(selValues))+1));
    [selValuesvtype,selValuessltype]=hdlgettypesfromsizes(maxSelValue,0,0);
    [selValuescsz,selValuescbp,selValuescsi]=hdlgetsizesfromtype(selValuessltype);


    outexp=hdlexpandvectorsignal(out);
    numout=length(outexp);


    str=[];
    if hdlgetparameter('isvhdl'),



        if strcmp(muxtype,'case_const')

            str=[str,construct_indent,'CASE ',hdlsignalname(sel),' IS \n'];
            for ii=1:length(in)-1,
                str=[str,choice_indent,'WHEN ',hdlconstantvalue(selValues(ii),selValuescsz,selValuescbp,selValuescsi,'bin'),' =>\n'];
                str=[str,assign_output(in{ii},out,subchoice_indent)];
            end
            str=[str,choice_indent,'WHEN OTHERS =>\n'];
            str=[str,assign_output(in{end},out,subchoice_indent)];
            str=[str,construct_indent,'END CASE;\n'];


        elseif strcmp(muxtype,'if_const')



            str=[str,construct_indent,'IF ',hdlsignalname(sel(1)),' = ',hdlconstantvalue(selValues(1),selValuescsz,selValuescbp,selValuescsi),' THEN \n'];
            str=[str,assign_output(in{1},out,choice_indent)];



            for ii=2:length(in)-1,
                str=[str,construct_indent,'ELSIF ',hdlsignalname(sel(ii)),' = ',hdlconstantvalue(selValues(ii),selValuescsz,selValuescbp,selValuescsi),' THEN \n'];
                str=[str,assign_output(in{ii},out,choice_indent)];
            end



            str=[str,construct_indent,'ELSE \n'];
            str=[str,assign_output(in{end},out,choice_indent)];



            str=[str,construct_indent,'END IF;\n'];


        elseif strcmp(muxtype,'case')


        elseif strcmp(muxtype,'if')


            str=[str,construct_indent,'IF ',hdlsignalname(sel(1)),' = ',hdlsignalname(selValues(1)),' THEN \n'];
            str=[str,assign_output(in{1},out,choice_indent)];



            for ii=2:length(in)-1,
                str=[str,construct_indent,'ELSIF ',hdlsignalname(sel(ii)),' = ',hdlsignalname(selValues(ii)),' THEN \n'];
                str=[str,assign_output(in{ii},out,choice_indent)];
            end



            str=[str,construct_indent,'ELSE \n'];
            str=[str,assign_output(in{end},out,choice_indent)];



            str=[str,construct_indent,'END IF;\n'];
        end







    else

        if strcmp(muxtype,'case_const')

            str=[str,construct_indent,'case ',hdlsignalname(sel),'\n'];
            len=length(in);
            for ii=1:len-1,
                str=[str,choice_indent,hdlconstantvalue(selValues(ii),selValuescsz,selValuescbp,selValuescsi),'      :\n'];
                assignstr=[assign_output(in{ii},out,subchoice_indent)];

                crs=strfind(assignstr,'\n');
                if length(crs)>1,
                    str=[str,subchoice_indent,'begin\n',strrep(assignstr,subchoice_indent,subsubchoice_indent),subchoice_indent,'end\n'];
                end

            end
            str=[str,choice_indent,'default:\n'];
            assignstr=[assign_output(in{end},out,subchoice_indent)];

            crs=strfind(assignstr,'\n');
            if length(crs)>1,
                str=[str,subchoice_indent,'begin\n',strrep(assignstr,subchoice_indent,subsubchoice_indent),subchoice_indent,'end\n'];
            end

            str=[str,construct_indent,'endcase;\n'];

        elseif strcmp(muxtype,'if_const')



            str=[str,construct_indent,'if (',hdlsignalname(sel(1)),' == ',hdlconstantvalue(selValues(1),selValuescsz,selValuescbp,selValuescsi),')'];
            str=[str,ver_if_assign_output(in{1},out,choice_indent,construct_indent)];




            for ii=2:length(in)-1,
                str=[str,construct_indent,'else if (',hdlsignalname(sel(ii)),' == ',hdlconstantvalue(selValues(ii),selValuescsz,selValuescbp,selValuescsi),')'];
                str=[str,ver_if_assign_output(in{ii},out,choice_indent,construct_indent)];
            end



            str=[str,construct_indent,'else'];
            str=[str,ver_if_assign_output(in{end},out,choice_indent,construct_indent)];

        elseif strcmp(muxtype,'case')

        elseif strcmp(muxtype,'if')



            str=[str,construct_indent,'if (',hdlsignalname(sel(1)),' == ',hdlsignalname(selValues(1)),') \n'];
            str=[str,ver_if_assign_output(in{1},out,choice_indent,construct_indent)];



            for ii=2:length(in)-1,
                str=[str,construct_indent,'else if (',hdlsignalname(sel(ii)),' == ',hdlsignalname(selValues(ii)),') \n'];
                str=[str,ver_if_assign_output(in{ii},out,choice_indent,construct_indent)];
            end



            str=[str,construct_indent,'else \n'];
            str=[str,ver_if_assign_output(in{end},out,choice_indent,construct_indent)];

        end

    end


    function str=assign_output(in,out,indent)


        outexp=hdlexpandvectorsignal(out);
        outcplx=hdlsignaliscomplex(out);


        if iscell(in),
            if isstruct(in{1}),
                incell=in;
                incplx=1;
            else
                for ii=1:length(in),
                    incell{ii}.real=in{ii};
                end
                incplx=0;
            end
        else
            inexp=hdlexpandvectorsignal(in);
            incplx=hdlsignaliscomplex(in);
            for ii=1:length(inexp),
                incell{ii}.real=inexp(ii).Name;
                if incplx,
                    in_imag=hdlsignalimag(inexp(ii));
                    incell{ii}.imag=in_imag.Name;
                end
            end
        end

        str=[];
        for jj=1:length(outexp)
            str=[str,indent,hdlsignalname(outexp(jj)),' <= ',incell{jj}.real,';\n'];
            if outcplx&&incplx,
                str=[str,indent,hdlsignalname(hdlsignalimag(outexp(jj))),' <= ',incell{jj}.imag,';\n'];
            end
        end




        function str=ver_if_assign_output(in,out,choice_indent,construct_indent)
            str=[];
            assignstr=assign_output(in,out,choice_indent);
            crs=strfind(assignstr,'\n');
            if length(crs)>1,
                str=[str,' begin\n',assignstr,construct_indent,'end\n'];
            else
                str=[str,'\n',assignstr];
            end
