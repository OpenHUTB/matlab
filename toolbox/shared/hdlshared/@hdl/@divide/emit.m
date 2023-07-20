function hdlcode=emit(this)





    hdlcode=hdlcodeinit;

    in1=this.inputs(1);
    name1=hdlsignalname(in1);
    vtype1=hdlsignalvtype(in1);
    sltype1=hdlsignalsltype(in1);
    [size1,bp1,signed1]=hdlwordsize(sltype1);

    in2=this.inputs(2);
    name2=hdlsignalname(in2);
    vtype2=hdlsignalvtype(in2);
    sltype2=hdlsignalsltype(in2);
    [size2,bp2,signed2]=hdlwordsize(sltype2);

    out=this.output;
    outname=hdlsignalname(out);
    outvtype=hdlsignalvtype(out);
    outsltype=hdlsignalsltype(out);
    [outsize,outbp,outsigned]=hdlwordsize(outsltype);
    resultsigned=outsigned;

    isReciprocal=this.type;
    if isempty(isReciprocal)
        isReciprocal=0;
    end

    divsize=size1;
    divbp=outbp;

    body='';


    if~any([size1,size2,outsize]==0)||...
        divsize~=outsize||divbp~=outbp||resultsigned~=outsigned






        [divbyzerop,divbyzerop_ptr]=hdlnewsignal('c_divbyzero_p','block',-1,0,0,outvtype,outsltype);
        t=realmax(fi(0,outsigned,outsize,outbp));
        cstring=hdlconstantvalue(t.data,outsize,outbp,outsigned);
        result=makehdlconstantdecl(divbyzerop_ptr,cstring);

        if(signed1&&(~isReciprocal))
            [divbyzeron,divbyzeron_ptr]=hdlnewsignal('c_divbyzero_n','block',-1,0,0,outvtype,outsltype);
            t=-realmax(fi(0,outsigned,outsize,outbp))-realmin(fi(0,outsigned,outsize,outbp));
            cstring=hdlconstantvalue(t.data,outsize,outbp,outsigned);
            result=makehdlconstantdecl(divbyzeron_ptr,cstring);

            [divbyzero,divbyzero_ptr]=hdlnewsignal('c_divbyzero','block',-1,0,0,outvtype,outsltype);
            body=[body,hdlmux([divbyzerop_ptr,divbyzeron_ptr],divbyzero_ptr,in1,...
            {'>='},0,'when-else'),'\n'];
        else
            divbyzero_ptr=divbyzerop_ptr;
        end

        namedivbyzero=hdlsignalname(divbyzero_ptr);
        sign=signed1+signed2;

        denominator=in2;

        if(sign)

            if(~signed2)
                [newvtype2,newsltype2]=hdlgettypesfromsizes(size2+1,bp2,1);
                [signedin2,signedin2_ptr]=hdlnewsignal('signedin2','block',-1,0,0,newvtype2,newsltype2);
                body=[body,hdldatatypeassignment(in2,signedin2_ptr,'Nearest',1)];
                name2=hdlsignalname(signedin2_ptr);
                denominator=signedin2_ptr;
                size2=size2+1;
                signed2=1;

            end

            if(~signed1)
                [newvtype1,newsltype1]=hdlgettypesfromsizes(size1+1,bp1,1);
                [signedin1,signedin1_ptr]=hdlnewsignal('signedin1','block',-1,0,0,newvtype1,newsltype1);
                body=[body,hdldatatypeassignment(in1,signedin1_ptr,'Nearest',1)];
                name1=hdlsignalname(signedin1_ptr);

            end
            if(~isReciprocal)
                divsize=divsize+1;
            end

            [divvtype,divsltype]=hdlgettypesfromsizes(divsize,divbp,1);


            if(hdlgetparameter('isvhdl')&&signed1&&(~isReciprocal))
                name1=hdltypeconvert(name1,size1,bp1,signed1,vtype1,divsize,bp1,1,divvtype,'nearest',1);
            end

        else
            divsize=size1;
            [divvtype,divsltype]=hdlgettypesfromsizes(divsize,divbp,0);

        end

        if(divsize==outsize)
            sametype=1;
            tempdiv=outname;
            tempdiv_ptr=out;
        else

            [tempdiv,tempdiv_ptr]=hdlnewsignal('div_temp','block',-1,0,0,divvtype,divsltype);
            sametype=0;
        end


        body=[body,...
        divbody(tempdiv_ptr,tempdiv,divsize,divbp,signed1,denominator,size2,bp2,signed2,name1,name2,namedivbyzero,sametype)];

        if(~sametype)

            [divout,divout_ptr]=hdlnewsignal('div_out','block',-1,0,0,outvtype,outsltype);
            body=[body,hdldatatypeassignment(tempdiv_ptr,divout_ptr,'Nearest',1)];
            body=[body,hdlmux([divbyzero_ptr,divout_ptr],out,denominator,...
            {'='},0,'when-else')];
        end

        hdlcode.arch_body_blocks=body;

        if strcmp(hdlcode.arch_body_blocks(end-3:end),'\n\n')
            hdlcode.arch_body_blocks=hdlcode.arch_body_blocks(1:end-2);
        end

    else
        hdlcode.arch_body_blocks=[body,...
        divbody(out,outname,divsize,divbp,resultsigned,in2,size2,bp2,signed2,name1,name2,name2,0)];

    end

    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,'\n'];


    if hdlconnectivity.genConnectivity,
        if exist('tempdiv_ptr')==1,
            conn_out=tempdiv_ptr;
        else
            conn_out=out;
        end
        hCD=hdlconnectivity.getConnectivityDirector;
        hCD.addDriverReceiverPair(in1,conn_out,'realonly',true);
        hCD.addDriverReceiverPair(in2,conn_out,'realonly',true);
    end




    function body=divbody(tempdiv_ptr,tempdiv,divsize,divbp,resultsigned,in2,size2,bp2,signed2,name1,name2,namedivbyzero,sametype)

        [assign_prefix,assign_op]=hdlassignforoutput(tempdiv_ptr);

        if(sametype)
            strconst=namedivbyzero;

        elseif divsize==0
            strconst='1.0E+308';
        else
            strconst=hdlconstantvalue(inf,divsize,divbp,resultsigned);
        end



        if hdlgetparameter('isvhdl')

            body=['  ',assign_prefix,tempdiv,' ',assign_op,' ',...
            strconst,...
            ' WHEN ',hdlsignalname(in2),' = ',hdlconstantvalue(0,size2,bp2,signed2),...
            ' ELSE ',name1,' / ',name2,';\n'];

        elseif hdlgetparameter('isverilog')

            if((resultsigned)&&(~sametype)&&(divsize>0))
                strconst=['$signed(',strconst,')'];
            end
            body=['  ',assign_prefix,tempdiv,' ',assign_op,' ',...
            '(',hdlsignalname(in2),' == ',hdlconstantvalue(0,size2,bp2,signed2),') ? ',...
            strconst,...
            ' : ',...
            name1,' / ',name2,';\n'];


        else
            error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
        end


