function[hdlbody,hdlsignal]=hdlrelop(in1,in2,out,op)












    op=hdleqop(op);

    [assign_prefix,assign_op]=hdlassignforoutput(out);

    name1=hdlsignalname(in1);
    vec1=hdlsignalvector(in1);
    vtype1=hdlsignalvtype(in1);
    sltype1=hdlsignalsltype(in1);

    name2=hdlsignalname(in2);
    vec2=hdlsignalvector(in2);
    vtype2=hdlsignalvtype(in2);
    sltype2=hdlsignalsltype(in2);

    outname=hdlsignalname(out);
    outvec=hdlsignalvector(out);
    outsltype=hdlsignalsltype(out);


    gConnOld=hdlconnectivity.genConnectivity(0);
    if gConnOld,
        hCD=hdlconnectivity.getConnectivityDirector;
        in1v=hdlexpandvectorsignal(in1);
        in2v=hdlexpandvectorsignal(in2);
        outv=hdlexpandvectorsignal(out);

    end



    [size,bp,signed]=hdlwordsize(sltype1);
    if size==1
        error(message('HDLShared:directemit:notsupported'));
    end

    if(length(outvec)==1&&outvec(1)<=1)

        name1=hdlsafeinput(in1,sltype1);
        name2=hdlsafeinput(in2,sltype2);
        [hdlbody,hdlsignal]=gencompare(name1,vec1,vtype1,sltype1,...
        name2,vec2,vtype2,sltype2,outname,outsltype,op,assign_prefix,assign_op);
        hdlbody=[hdlbody,'\n'];

        if gConnOld,
            hCD.addDriverReceiverPair(in1,out,'realonly',true);
            hCD.addDriverReceiverPair(in2,out,'realonly',true);
        end


    elseif(length(vec1)==1&&vec1(1)<=1)

        name1=hdlsafeinput(in1,sltype1);
        name2=hdlsafeinput(in2,sltype2,'k');
        [hdlbody,hdlsignal]=genbody_loop(name1,vec1,vtype1,sltype1,name2,vec2,vtype2,sltype2,...
        [outname,'(k)'],outsltype,op,max(outvec),assign_prefix,assign_op);

        if gConnOld,
            for ii=1:numel(outv),
                hCD.addDriverReceiverPair(in1,outv(ii),'realonly',true);
                hCD.addDriverReceiverPair(in2v(ii),outv(ii),'realonly',true);
            end
        end


    elseif(length(vec2)==1&&vec2(1)<=1)

        name1=hdlsafeinput(in1,sltype1,'k');
        name2=hdlsafeinput(in2,sltype2);
        [hdlbody,hdlsignal]=genbody_loop(name1,vec1,vtype1,sltype1,name2,vec2,vtype2,sltype2,...
        [outname,'(k)'],outsltype,op,max(outvec),assign_prefix,assign_op);

        if gConnOld,
            for ii=1:numel(outv),
                hCD.addDriverReceiverPair(in2,outv(ii),'realonly',true);
                hCD.addDriverReceiverPair(in1v(ii),outv(ii),'realonly',true);
            end
        end


    else

        name1=hdlsafeinput(in1,sltype1,'k');
        name2=hdlsafeinput(in2,sltype2,'k');
        [hdlbody,hdlsignal]=genbody_loop(name1,vec1,vtype1,sltype1,name2,vec2,vtype2,sltype2,...
        [outname,'(k)'],outsltype,op,max(outvec),assign_prefix,assign_op);

        if gConnOld,
            for ii=1:numel(outv),
                hCD.addDriverReceiverPair(in1v(ii),outv(ii),'realonly',true);
                hCD.addDriverReceiverPair(in2v(ii),outv(ii),'realonly',true);
            end
        end

    end


    hdlconnectivity.genConnectivity(gConnOld);



    function[hdlbody,hdlsignal]=genbody_loop(name1,vec1,vtype1,sltype1,name2,vec2,vtype2,sltype2,...
        outname,outsltype,op,vecsize,assign_prefix,assign_op)

        hdlsignal=[];
        genname=[outname(1:strfind(outname,'_out')-1),hdlgetparameter('block_generate_label')];
        hdlbody=[blanks(2),genname,' : ','FOR k IN 0 TO ',num2str(vecsize-1),' GENERATE\n'];
        [tmpbody,tmpsignal]=gencompare(name1,vec1,vtype1,sltype1,...
        name2,vec2,vtype2,sltype2,outname,outsltype,op,assign_prefix,assign_op);
        hdlsignal=[hdlsignal,tmpsignal];

        hdlbody=[hdlbody,tmpbody];
        hdlbody=[hdlbody,blanks(2),'END GENERATE;\n\n'];


        function[hdlbody,hdlsignal]=gencompare(name1,vec1,vtype1,sltype1,...
            name2,vec2,vtype2,sltype2,outname,outsltype,op,assign_prefix,assign_op)

            hdlbody=[];
            hdlsignal=[];

            [size1,bp1,signed1]=hdlwordsize(sltype1);
            [size2,bp2,signed2]=hdlwordsize(sltype2);
            [outsize,outbp,outsigned]=hdlwordsize(outsltype);

            if(strcmp(sltype1,sltype2))
                cond=[name1,blanks(1),op,blanks(1),name2];
            elseif(size1==0)||(size2==0)


                error(message('HDLShared:directemit:datatypeerror'));
            elseif((size1==1)&&(size2~=1))||((size1~=1)&&(size2==1))
                error(message('HDLShared:directemit:datatypeerror2'));
            elseif(signed1~=signed2)
                error(message('HDLShared:directemit:datatypeerror3'));
            else


                intL1=size1-bp1;
                intL2=size2-bp2;

                intL=max(intL1,intL2);
                bp=max(bp1,bp2);
                size=intL+bp;
                signed=signed1||signed2;
                vec=max(vec1,vec2);

                [vtype,sltype]=hdlgettypesfromsizes(size,bp,signed);
                vect_vtype=hdlvectorblockdatatype(0,vec,vtype,sltype);

                if((intL1~=intL)||(bp1~=bp))
                    input1=hdltypeconvert(name1,size1,bp1,signed1,vec1,...
                    size,bp,signed,vec,'Nearest',1);
                    if(vec1)
                        [nouse,tmpIdx]=hdlnewsignal('tmp1','block',-1,0,vec,vect_vtype,sltype);
                        tmpName1=hdlsafeinput(tmpIdx,sltype,'k');
                    else
                        [tmpName1,tmpIdx]=hdlnewsignal('tmp1','block',-1,0,0,vtype,sltype);
                    end
                    hdlbody=[hdlbody,blanks(2),assign_prefix,tmpName1,' ',assign_op,' ',input1,';\n'];

                else
                    tmpName1=name1;
                end

                if((intL2~=intL)||(bp2~=bp))
                    input2=hdltypeconvert(name2,size2,bp2,signed2,vec2,...
                    size,bp,signed,vec,'Nearest',1);
                    if(vec2)
                        [tmpName2,tmpIdx]=hdlnewsignal('tmp2','block',-1,0,vec,vect_vtype,sltype);
                        tmpName2=hdlsafeinput(tmpIdx,sltype,'k');
                    else
                        [tmpName2,tmpIdx]=hdlnewsignal('tmp2','block',-1,0,0,vtype,sltype);
                    end
                    hdlbody=[hdlbody,blanks(2),assign_prefix,tmpName2,' ',assign_op,' ',input2,';\n'];
                else
                    tmpName2=name2;
                end
                cond=[tmpName1,op,tmpName2];
            end

            strone=hdlconstantvalue(1,outsize,outbp,outsigned);
            strzero=hdlconstantvalue(0,outsize,outbp,outsigned);
            if hdlgetparameter('isvhdl')
                hdlbody=[hdlbody,blanks(2),assign_prefix,outname,' ',assign_op,' ',...
                strone,' WHEN ( ',cond,...
                ' ) ELSE ',strzero,';\n'];
            elseif hdlgetparameter('isverilog')
                hdlbody=[hdlbody,blanks(2),assign_prefix,outname,' ',assign_op,' ',...
                '(',cond,') ? ',strone,' : ',strzero,';\n'];
            else
                error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
            end
