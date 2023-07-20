function hdlbody=hdlcompareval(in,out,op,constval)











    vec=hdlsignalvector(in);
    sltype=hdlsignalsltype(in);
    outvec=hdlsignalvector(out);
    [insize,inbp,insigned]=hdlwordsize(sltype);

    op=hdleqop(op);


    if hdlsignaliscomplex(in)
        in_imag=hdlsignalimag(in);
    end



    gConnOld=hdlconnectivity.genConnectivity(0);
    if gConnOld,
        hCD=hdlconnectivity.getConnectivityDirector;
        hCD.addDriverReceiverPair(in,out,'realonly',~hdlsignaliscomplex(in));
    end



    if(insize==1)
        error(message('HDLShared:directemit:notsupported'));
    end

    outvecsize=max(outvec);

    if(length(outvec)==1&&outvec(1)<=1)

        if~hdlsignaliscomplex(in)
            name=hdlsafeinput(in,sltype);
            hdlbody=gencompare(name,sltype,out,'',constval,op);
        else
            name{1}=hdlsafeinput(in,sltype);
            name{2}=hdlsafeinput(in_imag,sltype);
            hdlbody=gencompare(name,sltype,out,'',constval,op);
        end
    elseif(length(vec)==1&&vec(1)<=1)
        if~hdlsignaliscomplex(in)
            name=hdlsafeinput(in,sltype);
        else
            name{1}=hdlsafeinput(in,sltype);
            name{2}=hdlsafeinput(in_imag,sltype);
        end
        if isequal(constval,ones(size(constval))*constval(1))

            hdlbody=gencompare(name,sltype,out,'',constval(1),op);
        else

            hdlbody=genbody_sv(name,constval,sltype,out,op,outvecsize);
        end
    else

        if isequal(constval,ones(size(constval))*constval(1))

            if hdlgetparameter('isvhdl')&&~hdlgetparameter('loop_unrolling')

                hdlbody=genbody_vs(in,constval,out,op,outvecsize);
            else
                hdlbody=genbody_vv(in,repmat(constval,1,outvecsize),out,op,outvecsize);
            end
        else

            hdlbody=genbody_vv(in,constval,out,op,outvecsize);
        end
    end

    hdlconnectivity.genConnectivity(gConnOld);
end






function hdlbody=gencompare(name,sltype,out,label,constval,op)


    if iscell(name)
        iscmplx=true;
        name_re=name{1};
        name_im=name{2};
        if strcmp(op,hdleqop('~='))
            condop=gethdlcondop('or');
        else
            condop=gethdlcondop('and');
        end
    else
        iscmplx=false;
        name_re=name;
    end
    [assign_prefix,assign_op]=hdlassignforoutput(out);

    [insize,inbp,insigned]=hdlwordsize(sltype);
    outname=[hdlsignalname(out),label];
    outsltype=hdlsignalsltype(out);
    [outsize,outbp,outsigned]=hdlwordsize(outsltype);
    constr=hdlconstantvalue(real(constval),insize,inbp,insigned,'noaggregate');
    if iscmplx
        constr2=hdlconstantvalue(imag(constval),insize,inbp,insigned,'noaggregate');
    end

    if hdlgetparameter('isverilog')&&insize~=0
        if insigned==1
            constr=['$signed(',constr,')'];
            if iscmplx
                constr2=['$signed(',constr2,')'];
            end
        end
    end

    cond=[name_re,blanks(1),op,blanks(1),constr];
    if iscmplx
        cond2=[name_im,blanks(1),op,blanks(1),constr2];
        cond=[cond,' ',condop,' ',cond2];
    end
    strone=hdlconstantvalue(1,outsize,outbp,outsigned);
    strzero=hdlconstantvalue(0,outsize,outbp,outsigned);

    if hdlgetparameter('isvhdl')
        hdlbody=[blanks(2),assign_prefix,outname,' ',assign_op,' ',...
        strone,' WHEN ( ',cond,...
        ' ) ELSE ',strzero,';\n'];
    elseif hdlgetparameter('isverilog')
        hdlbody=[blanks(2),assign_prefix,outname,' ',assign_op,' ',...
        '(',cond,') ? ',strone,' : ',strzero,';\n'];
    else
        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
    end
end

function hdlbody=genbody_sv(inname,cval,sltype,out,op,vecsize)
    hdlbody=[];
    for k=0:vecsize-1
        label=['(',num2str(k),')'];
        hdlbody=[hdlbody,gencompare(inname,sltype,out,label,cval(k+1),op)];
    end
end

function hdlbody=genbody_vs(in,cval,out,op,vecsize)

    sltype=hdlsignalsltype(in);
    outname=hdlsignalname(out);
    genname=[outname(1:strfind(outname,'_out')-1),hdlgetparameter('block_generate_label')];

    hdlbody=[blanks(2),genname,' : FOR k IN 0 TO ',num2str(vecsize-1),' GENERATE\n'];
    if~hdlsignaliscomplex(in)
        inlabel=hdlsafeinput(in,sltype,'k');
    else
        inlabel{1}=hdlsafeinput(in,sltype,'k');
        inlabel{2}=hdlsafeinput(hdlsignalimag(in),sltype,'k');
    end
    array_deref=hdlgetparameter('array_deref');
    label=[array_deref(1),'k',array_deref(2)];
    hdlbody=[hdlbody,blanks(2),gencompare(inlabel,sltype,out,label,cval(1),op)];
    hdlbody=[hdlbody,blanks(2),'END GENERATE;\n'];
end

function hdlbody=genbody_vv(in,cval,out,op,vecsize)

    sltype=hdlsignalsltype(in);
    hdlbody=[];
    array_deref=hdlgetparameter('array_deref');
    for k=0:vecsize-1
        if~hdlsignaliscomplex(in)
            inlabel=hdlsafeinput(in,sltype,num2str(k));
        else
            inlabel{1}=hdlsafeinput(in,sltype,num2str(k));
            inlabel{2}=hdlsafeinput(hdlsignalimag(in),sltype,num2str(k));
        end
        label=[array_deref(1),num2str(k),array_deref(2)];
        hdlbody=[hdlbody,gencompare(inlabel,sltype,out,label,cval(k+1),op)];
    end
end

function condop=gethdlcondop(cond)


    if hdlgetparameter('isverilog')
        switch lower(cond)
        case 'or'
            condop='||';
        case 'and'
            condop='&&';
        otherwise
            condop=cond;
        end
    else
        switch lower(cond)
        case 'or'
            condop='OR';
        case 'and'
            condop='AND';
        otherwise
            condop=cond;
        end
    end
end



