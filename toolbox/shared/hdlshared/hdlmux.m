function hdlbody=hdlmux(inidx,outidx,selidx,cmpstr,valarray,formatstr,inrange,outrange)








































    if~strcmpi(formatstr,'when-else')
        error(message('HDLShared:directemit:whenelse'))
    end


    if(hdlsignaliscomplex(selidx))
        error(message('HDLShared:directemit:muxselectiscomplex'));
    end


    gConnOld=hdlconnectivity.genConnectivity(0);


    [assign_prefix,assign_op]=hdlassignforoutput(outidx);

    selvec=hdlsignalvector(selidx);



    cplx=hdlsignaliscomplex(outidx);
    for ii=1:numel(inidx),
        cplx=cplx&&hdlsignaliscomplex(inidx(ii));
    end



    outname=hdlsignalname(outidx);
    if(cplx)
        outname_im=hdlsignalname(hdlsignalimag(outidx));
    end
    outvec=hdlsignalvector(outidx);
    outsltype=hdlsignalsltype(outidx);

    if(nargin<7)





        if gConnOld,
            hConnDir=hdlconnectivity.getConnectivityDirector;
            outv=hdlexpandvectorsignal(outidx);
            selv=hdlexpandvectorsignal(selidx);
            [selsize,selbp,selsigned]=hdlwordsize(hdlsignalsltype(selidx));

            loopc=numel(inidx);
            if selsize==1,
                loopc=2;
            end


            for ii=1:numel(inidx),
                isize(ii)=max([hdlsignalvector(inidx(ii)),1]);
            end

            isize=max(isize);

            if(isize==numel(outv))&&numel(selv)==1,
                muxNum=min([isize,numel(outv)]);

                for ii=1:muxNum,
                    hConnDir.addDriverReceiverPair(selv(1),outv(ii),'realonly',true);
                end
            else
                muxNum=min([isize,numel(outv),numel(selv)]);

                for ii=1:muxNum,
                    hConnDir.addDriverReceiverPair(selv(ii),outv(ii),'realonly',true);
                end
            end


            for jj=1:loopc,
                inv=hdlexpandvectorsignal(inidx(jj));
                if numel(inv)==1,
                    for ii=1:muxNum
                        hConnDir.addDriverReceiverPair(inv(1),outv(ii),'realonly',false);
                    end
                else

                    for ii=1:muxNum
                        hConnDir.addDriverReceiverPair(inv(ii),outv(ii),'realonly',false);
                    end
                end
            end
        end



        if(length(cmpstr)==1)&&(length(valarray)==1)&&any(selvec==0)







            hdlbody=scalarmux(inidx,selidx,cmpstr{1},valarray,...
            outname,outsltype,assign_prefix,assign_op);
            if(cplx)
                hdlbody=[hdlbody,scalarmux(hdlsignalimag(inidx),selidx,...
                cmpstr{1},valarray,outname_im,outsltype,...
                assign_prefix,assign_op)];
            end

        elseif(length(valarray)>1)&&all(selvec==0)


            hdlbody=multichoicemux(inidx,selidx,cmpstr,valarray,...
            outname,outsltype,assign_prefix,assign_op);
            if(cplx)
                hdlbody=[hdlbody,multichoicemux(hdlsignalimag(inidx),...
                selidx,cmpstr{1},valarray,outname_im,outsltype,...
                assign_prefix,assign_op)];
            end

        elseif(samecondstr(cmpstr,valarray)&&(~hdlgetparameter('loop_unrolling')))


            vec1=hdlsignalvector(inidx(1));
            genlabel=[outname,hdlgetparameter('block_generate_label')];
            hdlbody=[blanks(2),genlabel,' : ','FOR k IN 0 TO ',...
            num2str(max(outvec(:))-1),' GENERATE\n'];

            hdlbody=[hdlbody,indexedmux(inidx,selidx,cmpstr{1},...
            valarray(1),outname,outsltype,...
            assign_prefix,assign_op)];
            if(cplx)
                hdlbody=[hdlbody,indexedmux(hdlsignalimag(inidx),...
                selidx,cmpstr{1},valarray(1),outname_im,outsltype,...
                assign_prefix,assign_op)];
            end

            hdlbody=[hdlbody,blanks(2),'END GENERATE;\n'];

        else

            hdlbody=vectormux(inidx,selidx,cmpstr,valarray,...
            outname,outsltype,outvec,assign_prefix,assign_op);
            if(cplx)
                hdlbody=[hdlbody,vectormux(hdlsignalimag(inidx),...
                selidx,cmpstr,valarray,outname_im,outsltype,outvec,...
                assign_prefix,assign_op)];
            end
        end

    else


        selvec=hdlsignalvector(selidx);
        selveclen=max(max(selvec),1);
        invec=hdlsignalvector(inidx(1));
        inveclen=max(max(invec),1);
        outvec=hdlsignalvector(outidx(1));
        outveclen=max(max(outvec),1);



        if(selveclen>1&&length(inidx)>1&&selveclen==inveclen&&...
            inveclen==outveclen)






            if gConnOld,
                hConnDir=hdlconnectivity.getConnectivityDirector;
                outv=hdlexpandvectorsignal(outidx);
                selv=hdlexpandvectorsignal(selidx);
                [selsize,selbp,selsigned]=hdlwordsize(hdlsignalsltype(selidx));

                loopc=numel(inidx);
                if selsize==1,
                    loopc=2;
                end


                for ii=1:numel(inidx),
                    isize(ii)=max([hdlsignalvector(inidx(ii)),1]);
                end
                isize=min(isize);
                if(isize==numel(outv))&&numel(selv)==1,
                    muxNum=min([isize,numel(outv)]);

                    for ii=1:muxNum,
                        hConnDir.addDriverReceiverPair(selv(1),outv(ii),'realonly',true);
                    end
                else
                    muxNum=min([isize,numel(outv),numel(selv)]);

                    for ii=1:muxNum,
                        hConnDir.addDriverReceiverPair(selv(ii),outv(ii),'realonly',true);
                    end
                end

                for jj=1:loopc,
                    inv=hdlexpandvectorsignal(inidx(jj));
                    for ii=1:muxNum
                        hConnDir.addDriverReceiverPair(inv(ii),outv(ii),'realonly',false);
                    end
                end
            end

            hdlbody=vectorinputvectorselect(inidx,selidx,cmpstr,...
            outname,outsltype,outrange,assign_prefix,assign_op,...
            inrange);
            if(cplx)
                hdlbody=[hdlbody,vectorinputvectorselect(hdlsignalimag(inidx),...
                selidx,cmpstr,outname_im,outsltype,outrange,...
                assign_prefix,assign_op,inrange)];
            end
        else

            outv=hdlexpandvectorsignal(outidx);
            selv=hdlexpandvectorsignal(selidx);




            if gConnOld,
                hConnDir=hdlconnectivity.getConnectivityDirector;
                [selsize,selbp,selsigned]=hdlwordsize(hdlsignalsltype(selidx));


                if numel(inidx)==1,
                    muxNum=min([numel(outv),numel(selv)]);
                    inv=hdlexpandvectorsignal(inidx);
                    if isempty(inrange),
                        conIrange=[1:numel(inv)];
                    else
                        conIrange=inrange+1;
                    end
                    for ii=1:muxNum,
                        for jj=1:numel(conIrange),
                            hConnDir.addDriverReceiverPair(inv(conIrange(jj)),outv(ii),'realonly',false);
                        end
                        hConnDir.addDriverReceiverPair(selv(ii),outv(ii),'realonly',true);
                    end
                else
                    loopc=numel(inidx);
                    if selsize==1,
                        loopc=2;
                    end


                    for ii=1:numel(inidx),
                        isize(ii)=max([hdlsignalvector(inidx(ii)),1]);
                    end
                    isize=min(isize);
                    if(isize==numel(outv))&&numel(selv)==1,
                        muxNum=min([isize,numel(outv)]);

                        for ii=1:muxNum,
                            hConnDir.addDriverReceiverPair(selv(1),outv(ii),'realonly',true);
                        end
                    else
                        muxNum=min([isize,numel(outv),numel(selv)]);

                        for ii=1:muxNum,
                            hConnDir.addDriverReceiverPair(selv(ii),outv(ii),'realonly',true);
                        end
                    end
                    for jj=1:loopc,
                        inv=hdlexpandvectorsignal(inidx(jj));
                        for ii=1:muxNum
                            hConnDir.addDriverReceiverPair(inv(ii),outv(ii),'realonly',false);
                        end
                    end

                end

            end

            if hdlgetparameter('isverilog')&&numel(outv)>1&&numel(inidx)>1&&max(hdlsignalvector(inidx(1)))>1

                hdlbody=[];
                for ii=1:numel(inidx)
                    invects{ii}=hdlexpandvectorsignal(inidx(ii));
                end
                for ii=1:numel(outv)
                    outname=hdlsignalname(outv(ii));
                    for jj=1:numel(inidx)
                        tmpin(jj)=invects{jj}(ii);
                    end
                    hdlbody=[hdlbody,vectorselect(tmpin,selidx,cmpstr,outname,...
                    outsltype,outrange,assign_prefix,assign_op,inrange)];
                    if(cplx)
                        outname_im=hdlsignalname(hdlsignalimag(outv(ii)));
                        hdlbody=[hdlbody,vectorselect(hdlsignalimag(tmpin),...
                        selidx,cmpstr,outname_im,outsltype,outrange,...
                        assign_prefix,assign_op,inrange)];
                    end

                end
            else
                hdlbody=vectorselect(inidx,selidx,cmpstr,outname,...
                outsltype,outrange,assign_prefix,assign_op,inrange);
                if(cplx)
                    hdlbody=[hdlbody,vectorselect(hdlsignalimag(inidx),...
                    selidx,cmpstr,outname_im,outsltype,outrange,...
                    assign_prefix,assign_op,inrange)];
                end
            end
        end
    end

    if isempty(hdlbody)
        error(message('HDLShared:directemit:internalerror'));
    end


    hdlconnectivity.genConnectivity(gConnOld);


    [outsize,~,~]=hdlwordsize(hdlsignalsltype(outidx));
    vec=hdlsignalvector(outidx);
    vecsize=max(max(vec(:)),1);

    for i=1:(1+cplx)*vecsize
        resourceLog(numel(inidx),outsize,'mux');
    end




    function hdlbody=vectorinputvectorselect(inidx,selidx,cmpstr,...
        outname,outsltype,outrange,assign_prefix,assign_op,inrange)




        array_deref=hdlgetparameter('array_deref');
        hdlbody=[];


        selsltype=hdlsignalsltype(selidx);
        selvec=hdlsignalvector(selidx);
        selveclen=max(max(selvec),1);
        [selsize,selbp,selsigned]=hdlwordsize(selsltype);

        numinputs=length(inidx);


        if(selsize==1)
            numinputs=2;
        end


        for k=0:(selveclen-1)

            hdlbody=[hdlbody,blanks(2),assign_prefix,outname,...
            array_deref(1),num2str(k),array_deref(2),' ',assign_op,' '];

            for kk=1:numinputs-1

                if(length(outrange)==1)
                    thresholdstr=hdlconstantvalue(outrange(1),selsize,selbp,selsigned,'noaggregate');
                else
                    thresholdstr=hdlconstantvalue(outrange(kk),selsize,selbp,selsigned,'noaggregate');
                end

                if(length(cmpstr)==1)
                    op=cmpstr{1};
                else
                    op=cmpstr{kk};
                end
                cond=conditionstr(selidx,op,int2str(k),thresholdstr);


                name=hdlsafeinput(inidx(kk),outsltype,int2str(k));

                if hdlgetparameter('isvhdl')
                    hdlbody=[hdlbody,name,' WHEN ( ',cond,' ) ELSE\n',...
                    blanks(length(outname)+9)];
                elseif hdlgetparameter('isverilog')
                    hdlbody=[hdlbody,'(',cond,') ? ',name,' :\n',...
                    blanks(length(outname)+9)];
                else
                    error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
                end
            end



            hdlbody=[hdlbody,...
            hdlsafeinput(inidx(kk+1),outsltype,int2str(k)),...
            ';\n'];

        end


        function hdlbody=vectorselect(inidx,selidx,cmpstr,outname,outsltype,outrange,...
            assign_prefix,assign_op,inrange)


            array_deref=hdlgetparameter('array_deref');
            hdlbody=[];

            selsltype=hdlsignalsltype(selidx);
            selvec=hdlsignalvector(selidx);
            if selvec==0,
                selveclen=1;
            else
                selveclen=max(selvec);
            end
            [selsize,selbp,selsigned]=hdlwordsize(selsltype);

            if length(inidx)==1
                invec=hdlsignalvector(inidx);

                if(isempty(inrange))
                    numinputs=max(invec);

                    inrange=0:numinputs-1;
                else
                    numinputs=length(inrange);
                end
                is_vector_in=true;
            else
                numinputs=length(inidx);
                is_vector_in=false;
            end


            if(selsize==1)
                numinputs=2;
            end


            for k=0:(selveclen-1)


                if(selveclen==1)
                    hdlbody=[hdlbody,blanks(2),assign_prefix,outname,' ',assign_op,' '];
                else
                    hdlbody=[hdlbody,blanks(2),assign_prefix,outname,...
                    array_deref(1),num2str(k),array_deref(2),' ',assign_op,' '];
                end

                for kk=1:numinputs-1

                    if(length(outrange)==1)
                        thresholdstr=hdlconstantvalue(outrange(1),selsize,selbp,selsigned,'noaggregate');
                    else
                        thresholdstr=hdlconstantvalue(outrange(kk),selsize,selbp,selsigned,'noaggregate');
                    end

                    if(length(cmpstr)==1)
                        op=cmpstr{1};
                    else
                        op=cmpstr{kk};
                    end
                    cond=conditionstr(selidx,op,int2str(k),thresholdstr);
                    if is_vector_in

                        name=hdlsafeinput(inidx,outsltype,int2str(inrange(kk)));
                    else
                        name=hdlsafeinput(inidx(kk),outsltype);
                    end
                    if hdlgetparameter('isvhdl')
                        hdlbody=[hdlbody,name,' WHEN ( ',cond,' ) ELSE\n',...
                        blanks(length(outname)+9)];
                    elseif hdlgetparameter('isverilog')
                        hdlbody=[hdlbody,'(',cond,') ? ',name,' :\n',...
                        blanks(length(outname)+9)];
                    else
                        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
                    end

                end


                if is_vector_in
                    name=hdlsafeinput(inidx,outsltype,int2str(inrange(kk+1)));
                else
                    name=hdlsafeinput(inidx(numinputs),outsltype);
                end

                hdlbody=[hdlbody,name,';\n'];

            end


            function hdlbody=indexedmux(inidx,selidx,cmpstr,valarray,outname,outsltype,...
                assign_prefix,assign_op)


                array_deref=hdlgetparameter('array_deref');

                selsltype=hdlsignalsltype(selidx);
                [selsize,selbp,selsigned]=hdlwordsize(selsltype);
                numinputs=length(inidx);


                if(selsize==1)
                    numinputs=2;
                end


                hdlbody=[blanks(4),assign_prefix,outname,array_deref(1),'k',array_deref(2),...
                ' ',assign_op,' '];

                if iscell(valarray)
                    cond=conditionstr(selidx,cmpstr,'k',valarray{1});
                else
                    cond=conditionstr(selidx,cmpstr,'k',...
                    hdlconstantvalue(valarray,selsize,selbp,selsigned,'noaggregate'));
                end

                for k=1:numinputs-1
                    invec=hdlsignalvector(inidx(k));
                    if max(invec(:))>1
                        name=hdlsafeinput(inidx(k),outsltype,'k');
                    else
                        name=hdlsafeinput(inidx(k),outsltype);
                    end
                    if hdlgetparameter('isvhdl')
                        hdlbody=[hdlbody,name,' WHEN ( ',cond,' ) ELSE\n',...
                        blanks(length(outname)+11)];%#ok
                    elseif hdlgetparameter('isverilog')
                        hdlbody=[hdlbody,'(',cond,') ? ',name,' :\n',...
                        blanks(length(outname)+11)];%#ok
                    else
                        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
                    end
                end
                invec=hdlsignalvector(inidx(numinputs));
                if max(invec(:))>1
                    name=hdlsafeinput(inidx(numinputs),outsltype,'k');
                else
                    name=hdlsafeinput(inidx(numinputs),outsltype);
                end
                hdlbody=[hdlbody,name,';\n'];


                function boolflag=samecondstr(cmpstr,valarray)

                    boolflag=1;
                    for k=2:length(valarray)
                        if(~isequal(valarray(1),valarray(k)))
                            boolflag=0;
                            break;
                        end
                    end
                    for k=2:length(cmpstr)
                        if(~strcmp(cmpstr{1},cmpstr{k}))
                            boolflag=0;
                            break;
                        end
                    end



                    function hdlbody=vectormux(inidx,selidx,cmpstr,valarray,outname,outsltype,outvec,...
                        assign_prefix,assign_op)


                        array_deref=hdlgetparameter('array_deref');


                        inlen=length(inidx);
                        inveclen=zeros(inlen);
                        for i=1:inlen
                            inveclen(i)=max(max(hdlsignalvector(inidx(i))),1);
                        end
                        numinputs=length(inidx);
                        selsltype=hdlsignalsltype(selidx);
                        [selsize,selbp,selsigned]=hdlwordsize(selsltype);
                        hdlbody=[];

                        size_out=max(max(outvec),1);


                        for k=0:(size_out-1)
                            if(length(valarray)==1)
                                val_idx=1;
                            else
                                val_idx=k+1;
                            end

                            if iscell(valarray)
                                thresholdstr=valarray{val_idx};
                            else
                                thresholdstr=hdlconstantvalue(valarray(val_idx),...
                                selsize,selbp,selsigned,'noaggregate');
                            end


                            if(length(cmpstr)==1)
                                op=cmpstr{1};
                            else
                                op=cmpstr{k+1};
                            end

                            cond=conditionstr(selidx,op,int2str(k),thresholdstr);


                            hdlbody=[hdlbody,blanks(2),assign_prefix,outname,array_deref(1),num2str(k),array_deref(2),...
                            ' ',assign_op,' '];
                            for kk=1:numinputs-1
                                if(inveclen(kk)==1)
                                    name=hdlsafeinput(inidx(kk),outsltype);
                                else
                                    in_k=rem(k,inveclen(kk));
                                    name=hdlsafeinput(inidx(kk),outsltype,int2str(in_k));
                                end
                                if hdlgetparameter('isvhdl')
                                    hdlbody=[hdlbody,name,' WHEN ( ',cond,' ) ELSE\n',...
                                    blanks(length(outname)+9)];
                                elseif hdlgetparameter('isverilog')
                                    hdlbody=[hdlbody,'(',cond,') ? ',name,' :\n',...
                                    blanks(length(outname)+9)];
                                else
                                    error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
                                end
                            end

                            if(inveclen(numinputs)==1)
                                name=hdlsafeinput(inidx(numinputs),outsltype);
                            else
                                in_k=rem(k,inveclen(kk));
                                name=hdlsafeinput(inidx(numinputs),outsltype,int2str(in_k));
                            end
                            hdlbody=[hdlbody,name,';\n'];

                        end


                        function hdlbody=scalarmux(inidx,selidx,cmpstr,valarray,outname,outsltype,...
                            assign_prefix,assign_op)

                            array_deref=hdlgetparameter('array_deref');

                            selsltype=hdlsignalsltype(selidx);
                            [selsize,selbp,selsigned]=hdlwordsize(selsltype);
                            numinputs=length(inidx);


                            if(selsize==1)
                                numinputs=2;
                            end


                            vectlen=zeros(1,numinputs);
                            for ii=1:numinputs
                                vectlen(ii)=max(hdlsignalvector(inidx(ii)));
                            end
                            vect=max(vectlen);


                            anystdlogic=false;
                            for ii=1:length(inidx)
                                if vhdlisstdlogicvector(inidx(ii))
                                    anystdlogic=true;
                                    break;
                                end
                            end

                            simplecase=false;
                            if(all(vect)==0)||...
                                (hdlgetparameter('isvhdl')&&...
                                ~hdlgetparameter('loop_unrolling')&&...
                                ~anystdlogic&&...
                                all(vectlen==vect))
                                vect=1;
                                simplecase=true;
                            end

                            hdlbody='';
                            for ii=0:vect-1
                                if vect>1
                                    slicen=num2str(ii);
                                    outslicename=[outname,array_deref(1),slicen,array_deref(2)];
                                else
                                    outslicename=outname;
                                end


                                hdlbody=[hdlbody,blanks(2),assign_prefix,outslicename,' ',assign_op,' '];

                                for k=1:numinputs-1
                                    if~simplecase&&vectlen(k)>1
                                        name=hdlsafeinput(inidx(k),outsltype,slicen);
                                    else
                                        name=hdlsafeinput(inidx(k),outsltype);
                                    end

                                    if iscell(valarray)
                                        constval=valarray{k};
                                    else
                                        constval=hdlconstantvalue(valarray(k),selsize,selbp,selsigned,'noaggregate');

                                    end


                                    cond=conditionstr(selidx,cmpstr,'0',constval);

                                    if hdlgetparameter('isvhdl')
                                        hdlbody=[hdlbody,name,' WHEN ( ',cond,' ) ELSE\n',...
                                        blanks(length(outslicename)+6)];
                                    elseif hdlgetparameter('isverilog')
                                        hdlbody=[hdlbody,'(',cond,') ? ',name,' :\n',...
                                        blanks(length(outslicename)+6)];
                                    else
                                        error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
                                    end
                                end
                                if~simplecase&&vectlen(numinputs)>1
                                    name=hdlsafeinput(inidx(numinputs),outsltype,slicen);
                                else
                                    name=hdlsafeinput(inidx(numinputs),outsltype);
                                end
                                hdlbody=[hdlbody,name,';\n'];
                            end


                            function cond=conditionstr(ctrl,cmpstr,loopindexstr,valstr)




                                ctrlvec=hdlsignalvector(ctrl);
                                ctrlsltype=hdlsignalsltype(ctrl);
                                [ctrlsize,ctrlbp,ctrlsigned]=hdlwordsize(ctrlsltype);

                                if(length(ctrlvec)==1&&ctrlvec(1)<=1)
                                    ctrlname=hdlsafeinput(ctrl,ctrlsltype);
                                else
                                    ctrlname=hdlsafeinput(ctrl,ctrlsltype,loopindexstr);
                                end


                                if(iscell(cmpstr))
                                    cmpstr=cmpstr{1};
                                end

                                op=hdleqop(cmpstr);


                                valstr=signedverilog(valstr,ctrlsize,ctrlsigned);


                                cond=[ctrlname,' ',op,' ',valstr];


                                function hdlbody=multichoicemux(inidx,selidx,cmpstr,valarray,outname,outsltype,...
                                    assign_prefix,assign_op)


                                    selsltype=hdlsignalsltype(selidx);
                                    [selsize,selbp,selsigned]=hdlwordsize(selsltype);
                                    numinputs=length(inidx);


                                    if(selsize==1)
                                        numinputs=2;
                                    end


                                    hdlbody=[blanks(2),assign_prefix,outname,' ',assign_op,' '];

                                    for k=1:numinputs-1
                                        if length(cmpstr)==1
                                            cmpstr_k=cmpstr;
                                        else
                                            cmpstr_k=cmpstr(k);
                                        end

                                        if iscell(valarray)
                                            cond=conditionstr(selidx,cmpstr_k,'k',valarray{k});
                                        else
                                            cond=conditionstr(selidx,cmpstr_k,'k',...
                                            hdlconstantvalue(valarray(k),selsize,selbp,selsigned,'noaggregate'));
                                        end

                                        name=hdlsafeinput(inidx(k),outsltype);
                                        if hdlgetparameter('isvhdl')
                                            hdlbody=[hdlbody,name,' WHEN ( ',cond,' ) ELSE\n',...
                                            blanks(length(outname)+11)];
                                        elseif hdlgetparameter('isverilog')
                                            hdlbody=[hdlbody,'(',cond,') ? ',name,' :\n',...
                                            blanks(length(outname)+11)];
                                        else
                                            error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
                                        end
                                    end
                                    name=hdlsafeinput(inidx(numinputs),outsltype);
                                    hdlbody=[hdlbody,name,';\n'];


                                    function constval=signedverilog(constval,selsize,selsigned)

                                        if hdlgetparameter('isverilog')&&selsize~=0
                                            if(selsigned==1)
                                                constval=['$signed(',constval,')'];
                                            end
                                        end





