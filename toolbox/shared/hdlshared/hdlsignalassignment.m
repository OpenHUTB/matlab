function hdlbody=hdlsignalassignment(in,out,inrange,outrange,label)





























    invector=hdlsignalvector(in);
    outname=hdlsignalname(out);
    outvector=hdlsignalvector(out);
    if hdlgetparameter('isvhdl')
        ismodinport=vhdlisstdlogicvector(in);
    else
        ismodinport=false;
    end

    if(nargin<3)
        inrange=[];
        outrange=[];
    end










    gConnOld=hdlconnectivity.genConnectivity(0);
    if gConnOld,
        realonly=~(hdlsignaliscomplex(in)&&hdlsignaliscomplex(out));
        hCD=hdlconnectivity.getConnectivityDirector;
        if all(invector==0),

            if all(outvector==0),



                hCD.addDriverReceiverPair(in,out,'realonly',realonly,'unroll',false);

            else

                if~isempty(outrange)
                    hCD.addDriverReceiverPair(in,out,'realonly',realonly,...
                    'unroll',false,'receiverIndices',outrange(1));
                end
            end

        else


            if all(outvector==0)
                if~isempty(inrange),
                    hCD.addDriverReceiverPair(in,out,'realonly',realonly,...
                    'unroll',false,'driverIndices',inrange(1));
                end

            else
                if isempty(inrange),
                    drvrIndices=(0:max(invector)-1);
                else
                    drvrIndices=inrange;
                end

                if isempty(outrange),
                    rcvrIndices=(0:max(outvector)-1);
                else
                    rcvrIndices=outrange;
                end

                minIndices=min(numel(drvrIndices),numel(rcvrIndices));
                for ii=1:(minIndices),
                    hCD.addDriverReceiverPair(in,out,'realonly',realonly,...
                    'unroll',false,...
                    'receiverIndices',rcvrIndices(ii),...
                    'driverIndices',drvrIndices(ii));
                end
            end
        end
    end









    if(all(invector==0)||all(outvector==0))

        hdlbody=onescalarport(in,out,inrange,outrange);

    else

        if~ismodinport&&monotonic(inrange,outrange)&&...
            ((~isempty(inrange)&&~isempty(outrange))||...
            (isempty(inrange)&&isempty(outrange)))


            hdlbody=equallengthvectorports(in,out,inrange,outrange);

        elseif~ismodinport&&monotonic(inrange,outrange)&&(length(inrange)==max(outvector))
            if max(invector)==length(inrange)
                inrange=[];
                outrange=[];
            else
                outrange=0:max(outvector)-1;
            end
            hdlbody=equallengthvectorports(in,out,inrange,outrange);

        elseif((hdlgetparameter('loop_unrolling')==0)&&monotonic(inrange,outrange))

            if(nargin==5)
                if isempty(label)
                    isloop=1;
                    genlabel=[];
                else
                    isloop=0;
                    genlabel=sprintf('%s%s',label,hdlgetparameter('block_generate_label'));
                end
            else
                isloop=0;
                genlabel=sprintf('%s%s',outname,hdlgetparameter('block_generate_label'));
            end

            hdlbody=genloop(in,out,inrange,outrange,genlabel,isloop);

        else

            hdlbody=unrollvector(in,out,inrange,outrange);

        end

    end


    hdlconnectivity.genConnectivity(gConnOld);





    function hdlbody=genloop(in,out,inrange,outrange,genlabel,isloop)

        [assign_prefix,assign_op]=hdlassignforoutput(out);
        array_deref=hdlgetparameter('array_deref');

        insltype=hdlsignalsltype(in);
        invector=hdlsignalvector(in);
        incplx=hdlsignaliscomplex(in);
        outname=hdlsignalname(out);
        outsltype=hdlsignalsltype(out);
        outvector=hdlsignalvector(out);
        outcplx=hdlsignaliscomplex(out);
        if(outcplx),outname_im=hdlsignalname(hdlsignalimag(out));end


        outidxchar='k';
        inidxchar='k';
        if isempty(inrange)&&isempty(outrange)
            loopcount=int2str(max(outvector)-1);
        elseif isempty(inrange)&&~isempty(outrange)
            if(outrange(1)~=0),outidxchar=[outidxchar,'+',num2str(outrange(1))];end
            loopcount=int2str(max(invector)-1);
        elseif~isempty(inrange)&&isempty(outrange)
            if(inrange(1)~=0),inidxchar=[inidxchar,'+',num2str(inrange(1))];end
            loopcount=int2str(max(outvector)-1);
        else
            loopcount=int2str(length(inrange)-1);
            if inrange(1)<outrange(1)
                outidxchar=[outidxchar,'+',num2str(outrange(1)-inrange(1))];
            elseif inrange(1)>outrange(1)
                inidxchar=[inidxchar,'+',num2str(inrange(1)-outrange(1))];
            end
        end
        if(isloop)
            hdlbody=['  FOR k IN 0 TO ',loopcount,' LOOP\n'];
        else
            hdlbody=['  ',genlabel,':FOR k IN 0 TO ',loopcount,' GENERATE\n'];
        end


        inname=hdlsafeinput(in,outsltype,inidxchar);
        hdlbody=[hdlbody,'    ',assign_prefix,outname,...
        array_deref(1),outidxchar,array_deref(2),...
        ' ',assign_op,' ',inname,';\n'];
        if outcplx
            if(incplx)
                inname_im=hdlsafeinput(hdlsignalimag(in),outsltype,inidxchar);
                hdlbody=[hdlbody,'    ',assign_prefix,outname_im,...
                array_deref(1),outidxchar,array_deref(2),...
                ' ',assign_op,' ',inname_im,';\n'];
            else
                hdlbody=[hdlbody,'    ',assign_prefix,outname_im,...
                array_deref(1),outidxchar,array_deref(2),...
                ' ',assign_op,' ',getzerostr(insltype),';\n'];
            end
        end


        if(isloop)
            hdlbody=[hdlbody,'  END LOOP;\n\n'];
        else
            hdlbody=[hdlbody,'  END GENERATE;\n\n'];
        end


        function hdlbody=unrollvector(in,out,inrange,outrange)



            [assign_prefix,assign_op]=hdlassignforoutput(out);

            insltype=hdlsignalsltype(in);
            incplx=hdlsignaliscomplex(in);
            outname=hdlsignalname(out);
            outsltype=hdlsignalsltype(out);
            outcplx=hdlsignaliscomplex(out);

            if(outcplx),outname_im=hdlsignalname(hdlsignalimag(out));end

            hdlbody=vectorassign_unroll(in,outname,outsltype,inrange,outrange,...
            assign_prefix,assign_op);
            if outcplx
                if incplx
                    hdlbody=[hdlbody,vectorassign_unroll(hdlsignalimag(in),...
                    outname_im,outsltype,inrange,outrange,assign_prefix,assign_op)];
                else
                    hdlbody=[hdlbody,vectorassignzero_unroll(getzerostr(insltype),...
                    outname_im,outrange,assign_prefix,assign_op)];
                end
            end


            function hdlbody=onescalarport(in,out,inrange,outrange)

                [assign_prefix,assign_op]=hdlassignforoutput(out);
                array_deref=hdlgetparameter('array_deref');

                insltype=hdlsignalsltype(in);
                incplx=hdlsignaliscomplex(in);
                outname=hdlsignalname(out);
                outsltype=hdlsignalsltype(out);
                outcplx=hdlsignaliscomplex(out);

                inr='';

                if(outcplx),outname_im=hdlsignalname(hdlsignalimag(out));end

                if~isempty(outrange)
                    outname=[outname,array_deref(1),num2str(outrange(1)),array_deref(2)];
                    if(outcplx)
                        outname_im=[outname_im,array_deref(1),num2str(outrange(1)),...
                        array_deref(2)];
                    end
                elseif~isempty(inrange)
                    inr=num2str(inrange(1));
                end

                hdlbody=scalarassign(in,outname,outsltype,inr,assign_prefix,assign_op);

                if(outcplx)
                    if incplx
                        hdlbody=[hdlbody,scalarassign(hdlsignalimag(in),outname_im,...
                        outsltype,inr,assign_prefix,assign_op)];
                    else
                        hdlbody=[hdlbody,'  ',assign_prefix,outname_im,...
                        ' ',assign_op,' ',getzerostr(insltype),';\n\n'];
                    end
                end


                function hdlbody=equallengthvectorports(in,out,inrange,outrange)

                    [assign_prefix,assign_op]=hdlassignforoutput(out);
                    array_deref=hdlgetparameter('array_deref');

                    invector=hdlsignalvector(in);
                    incplx=hdlsignaliscomplex(in);
                    outname=hdlsignalname(out);
                    outvector=hdlsignalvector(out);
                    outsltype=hdlsignalsltype(out);
                    outcplx=hdlsignaliscomplex(out);

                    if(outcplx),outname_im=hdlsignalname(hdlsignalimag(out));end

                    if hdlgetparameter('isvhdl')
                        if(isempty(inrange)&&isempty(outrange))
                            hdlbody=scalarassign(in,outname,outsltype,[],assign_prefix,...
                            assign_op);
                            if(outcplx)
                                if(incplx)
                                    hdlbody=[hdlbody,scalarassign(hdlsignalimag(in),...
                                    outname_im,outsltype,[],assign_prefix,assign_op)];
                                else
                                    error(message('HDLShared:directemit:equallengthports'));
                                end
                            end

                        else
                            if hdlgetparameter('isvhdl')
                                rangemark=' TO ';
                            else
                                rangemark=':';
                            end
                            if inrange(1)~=inrange(end)
                                inr=[int2str(inrange(1)),rangemark,int2str(inrange(end))];
                            else
                                inr=int2str(inrange(1));
                            end
                            if outrange(1)~=outrange(end)
                                outr=[int2str(outrange(1)),rangemark,int2str(outrange(end))];
                            else
                                outr=int2str(outrange(1));
                            end
                            outname=[outname,array_deref(1),outr,array_deref(2)];
                            hdlbody=scalarassign(in,outname,outsltype,inr,assign_prefix,...
                            assign_op);
                            if(outcplx)
                                outname_im=[outname_im,array_deref(1),outr,array_deref(2)];
                            end
                            if(outcplx)
                                if(incplx)
                                    hdlbody=[hdlbody,scalarassign(hdlsignalimag(in),...
                                    outname_im,outsltype,inr,assign_prefix,assign_op)];
                                else
                                    error(message('HDLShared:directemit:equallengthports2'));
                                end
                            end

                        end
                    elseif hdlgetparameter('isverilog')
                        if isempty(inrange)
                            inrange=0:max(invector)-1;
                        end
                        if isempty(outrange)
                            outrange=0:max(outvector)-1;
                        end
                        hdlbody='';
                        for v=1:length(inrange)
                            inr=num2str(inrange(v));
                            tmpname=[outname,array_deref(1),...
                            num2str(outrange(v)),array_deref(2)];
                            hdlbody=[hdlbody,scalarassign(in,tmpname,outsltype,inr,...
                            assign_prefix,assign_op)];
                            if(outcplx)
                                if(incplx)
                                    tmpname=[outname_im,array_deref(1),...
                                    num2str(outrange(v)),array_deref(2)];
                                    hdlbody=[hdlbody,scalarassign(hdlsignalimag(in),...
                                    tmpname,outsltype,inr,assign_prefix,assign_op)];
                                else
                                    error(message('HDLShared:directemit:equallengthports2'));
                                end
                            end
                        end
                    end


                    function hdlbody=scalarassign(in,outname,outsltype,index,...
                        assign_prefix,assign_op)

                        if nargin==3||isempty(index)
                            inname=hdlsafeinput(in,outsltype);
                        else
                            inname=hdlsafeinput(in,outsltype,index);
                        end


                        insltype=hdlsignalsltype(in);
                        [isize,ibp,isigned]=hdlwordsize(insltype);
                        [osize,obp,osigned]=hdlwordsize(outsltype);

                        if~isigned&&osigned&&hdlgetparameter('isvhdl')
                            inname=['resize(',inname,', ',num2str(osize),')'];
                        end

                        hdlbody=['  ',assign_prefix,outname,...
                        ' ',assign_op,' ',inname,';\n\n'];



                        function hdlbody=vectorassign_unroll(in,outname,outsltype,inrange,...
                            outrange,assign_prefix,assign_op)

                            array_deref=hdlgetparameter('array_deref');

                            hdlbody=[];

                            if isempty(inrange)
                                for k=0:length(outrange)-1
                                    inname=hdlsafeinput(in,outsltype,int2str(k));
                                    hdlbody=[hdlbody,'  ',assign_prefix,outname,...
                                    array_deref(1),int2str(outrange(k+1)),array_deref(2),...
                                    ' ',assign_op,' ',inname,';\n'];
                                end
                                hdlbody=[hdlbody,'\n'];

                            elseif isempty(outrange)
                                for k=0:length(inrange)-1
                                    inname=hdlsafeinput(in,outsltype,int2str(inrange(k+1)));
                                    hdlbody=[hdlbody,'  ',assign_prefix,outname,...
                                    array_deref(1),int2str(k),array_deref(2),...
                                    ' ',assign_op,' ',inname,';\n'];
                                end
                                hdlbody=[hdlbody,'\n'];

                            else
                                if length(inrange)==length(outrange)
                                    for k=0:length(inrange)-1
                                        inname=hdlsafeinput(in,outsltype,int2str(inrange(k+1)));
                                        hdlbody=[hdlbody,'  ',assign_prefix,outname,...
                                        array_deref(1),int2str(outrange(k+1)),array_deref(2),...
                                        ' ',assign_op,' ',inname,';\n'];
                                    end
                                    hdlbody=[hdlbody,'\n'];
                                else
                                    error(message('HDLShared:directemit:invalidranges'));
                                end

                            end


                            function hdlbody=vectorassignzero_unroll(zerostr,outname,outrange,...
                                assign_prefix,assign_op)

                                array_deref=hdlgetparameter('array_deref');

                                hdlbody=[];
                                for k=0:length(outrange)-1
                                    hdlbody=[hdlbody,'  ',assign_prefix,outname,...
                                    array_deref(1),int2str(outrange(k+1)),array_deref(2),...
                                    ' ',assign_op,' ',zerostr,';\n'];
                                end
                                hdlbody=[hdlbody,'\n'];


                                function str=getzerostr(sltype)
                                    [size,bp,signed]=hdlwordsize(sltype);
                                    str=hdlconstantvalue(0,size,bp,signed);


                                    function result=monotonic(a,b)


                                        if isempty(a)&&isempty(b)
                                            result=true;
                                        elseif isempty(a)&&(~isempty(b))
                                            b=b(:)';
                                            b=b-b(1);
                                            if all(b==0:length(b)-1)
                                                result=true;
                                            else
                                                result=false;
                                            end
                                        elseif(~isempty(a))&&isempty(b)
                                            a=a(:)';
                                            a=a-a(1);
                                            if all(a==0:length(a)-1)
                                                result=true;
                                            else
                                                result=false;
                                            end
                                        elseif length(a)~=length(b)
                                            result=false;
                                        elseif any(a<0)||any(b<0)
                                            result=false;
                                        elseif(length(a)==1)
                                            result=true;
                                        else
                                            a=a-a(1);
                                            b=b-b(1);
                                            if all(a==0:length(a)-1)&&all(b==0:length(b)-1)
                                                result=true;
                                            else
                                                result=false;
                                            end
                                        end




