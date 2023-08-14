function hdlcode=emit(this,ins,outs,sat,rnd,isMath)

    hdlcode=hdlcodeinit;
    body='';
    signals='';
    insltype=hdlsignalsltype(ins);
    [insize,inbp,insigned]=hdlwordsize(insltype);

    outsltype=hdlsignalsltype(outs);
    [outsize,outbp,outsigned]=hdlwordsize(outsltype);


    onebp=inbp+outbp;
    onesigned=insigned;
    if(onesigned)
        onesize=onebp+2;
    else
        onesize=onebp+1;
    end

    [vtype,sltype]=hdlgettypesfromsizes(onesize,onebp,onesigned);
    [xvtype,xsltype]=hdlgettypesfromsizes(insize,inbp,insigned);
    [yvtype,ysltype]=hdlgettypesfromsizes(outsize,outbp,outsigned);
    [cmpvtype,cmpsltype]=hdlgettypesfromsizes(1,0,0);




    ufix1_in=~insigned&&(insize==1);
    ufix1_out=~outsigned&&(outsize==1);
    sfix2_in=insigned&&(insize==2);
    sfix2_out=outsigned&&(outsize==2);

    if(ufix1_in||sfix2_in)

        [divzero,divzero_ptr]=hdlnewsignal('Divzero','block',-1,0,0,yvtype,ysltype);
        divzero_value=realmax(fi(0,outsigned,outsize,outbp));
        cstring=hdlconstantvalue(divzero_value,outsize,outbp,outsigned);
        result=makehdlconstantdecl(divzero_ptr,cstring);

        [divonep,divonep_ptr]=hdlnewsignal('Divone_pos','block',-1,0,0,yvtype,ysltype);
        divonep_value=2^inbp;
        cstring=hdlconstantvalue(divonep_value,outsize,outbp,outsigned);
        result=makehdlconstantdecl(divonep_ptr,cstring);

        if(ufix1_in)

            [ufix2vtype,ufix2sltype]=hdlgettypesfromsizes(2,inbp,insigned);
            [ufix2,ufix2_ptr]=hdlnewsignal('Ufix2','block',-1,0,0,ufix2vtype,ufix2sltype);
            body=[body,hdldatatypeassignment(ins,ufix2_ptr,'Nearest',1)];
            tempin=ufix2_ptr;
        else
            tempin=ins;
        end

        [cmpzero,cmpzero_ptr]=hdlnewsignal('Cmpzero','block',-1,0,0,cmpvtype,cmpsltype);
        compare_sign=hdleqop('==');

        body=[body,hdlcompareval(tempin,cmpzero_ptr,compare_sign,0)];


        if(sfix2_in)
            [cmpsign,cmpsign_ptr]=hdlnewsignal('Cmpsign','block',-1,0,0,cmpvtype,cmpsltype);
            [signout,signout_ptr]=hdlnewsignal('Signout','block',-1,0,0,yvtype,ysltype);
            compare_sign=hdleqop('>=');

            body=[body,hdlcompareval(ins,cmpsign_ptr,compare_sign,0)];

            [divonen,divonen_ptr]=hdlnewsignal('Divone_neg','block',-1,0,0,yvtype,ysltype);
            if(outsigned)
                divonen_value=-2^inbp;
            else
                divonen_value=0;
            end
            cstring=hdlconstantvalue(divonen_value,outsize,outbp,outsigned);
            result=makehdlconstantdecl(divonen_ptr,cstring);

            body=[body,hdlmux([divonep_ptr,divonen_ptr],signout_ptr,cmpsign_ptr,...
            {'='},1,'when-else'),'\n'];
            divone=signout_ptr;
        else

            divone=divonep_ptr;
        end


        body=[body,hdlmux([divzero_ptr,divone],outs,cmpzero_ptr,...
        {'='},1,'when-else'),'\n'];


    else
        if(ufix1_out||sfix2_out)

            [zero,zero_ptr]=hdlnewsignal('Const_zero','block',-1,0,0,yvtype,ysltype);
            cstring=hdlconstantvalue(0,outsize,outbp,outsigned);
            result=makehdlconstantdecl(zero_ptr,cstring);

            [one,one_ptr]=hdlnewsignal('Const_Hexone','block',-1,0,0,yvtype,ysltype);
            t=realmax(fi(0,outsigned,outsize,outbp));
            one_value=1/t.data;
            cstring=hdlconstantvalue(t.data,outsize,outbp,outsigned);
            result=makehdlconstantdecl(one_ptr,cstring);

            if(sfix2_out)

                [cmpsign,cmpsign_ptr]=hdlnewsignal('Cmpsign','block',-1,0,0,cmpvtype,cmpsltype);
                compare_sign=hdleqop('>=');
                body=[body,hdlcompareval(ins,cmpsign_ptr,compare_sign,0)];

                if(insigned)
                    [inneg,inneg_ptr]=hdlnewsignal('In_neg','block',-1,0,0,xvtype,xsltype);
                    body=[body,hdlunaryminus(ins,inneg_ptr,'Nearest',1)];
                    [absin,absin_ptr]=hdlnewsignal('Absin','block',-1,0,0,xvtype,xsltype);
                    body=[body,hdlmux([ins,inneg_ptr],absin_ptr,cmpsign_ptr,...
                    {'='},1,'when-else'),'\n'];
                    tempin=absin_ptr;
                else
                    tempin=ins;
                end

                [negone,negone_ptr]=hdlnewsignal('Const_negone','block',-1,0,0,yvtype,ysltype);
                cstring=hdlconstantvalue(-t.data,outsize,outbp,outsigned);
                result=makehdlconstantdecl(negone_ptr,cstring);

                [oneout,oneout_ptr]=hdlnewsignal('Oneout','block',-1,0,0,yvtype,ysltype);

                body=[body,hdlmux([one_ptr,negone_ptr],oneout_ptr,cmpsign_ptr,...
                {'='},1,'when-else'),'\n'];

                tempone=oneout_ptr;
            else
                tempin=ins;
                tempone=one_ptr;
            end

            [cmpone,cmpone_ptr]=hdlnewsignal('Cmpone','block',-1,0,0,cmpvtype,cmpsltype);
            compare_sign=hdleqop('<=');

            body=[body,hdlcompareval(tempin,cmpone_ptr,compare_sign,one_value)];

            body=[body,hdlmux([zero_ptr,tempone],outs,cmpone_ptr,...
            {'='},0,'when-else'),'\n'];


        else


            [one,one_ptr]=hdlnewsignal('One','block',-1,0,0,vtype,sltype);
            cstring=hdlconstantvalue(1,onesize,onebp,onesigned);
            result=makehdlconstantdecl(one_ptr,cstring);

            hDiv=hdl.divide('inputs',[one_ptr,ins],'output',outs,'rounding',rnd,'saturation',sat,'type',isMath);
            Divhdlcode=hDiv.emit;

            body=[body,Divhdlcode.arch_body_blocks];

        end
    end


    hdlcode.arch_signals=[hdlcode.arch_signals,signals];
    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,body];


