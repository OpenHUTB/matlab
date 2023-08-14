function hdlbody=hdldatatypeassignment(in,out,rounding,saturation,label,assign_type)































    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if~emitMode
        if saturation==0
            satMode='Wrap';
        else
            satMode='Saturate';
        end
        pirelab.getDTCComp(hN,in,out,rounding,satMode);
        hdlbody='';
    else

        gConnOld=hdlconnectivity.genConnectivity(0);

        [assign_prefix,assign_op]=hdlassignforoutput(out);

        invector=hdlsignalvector(in);
        inveclen=max(max(invector,1));
        incomplex=hdlsignaliscomplex(in);
        invtype=hdlsignalvtype(in);
        insltype=hdlsignalsltype(in);
        [insize,inbp,insigned]=hdlwordsize(insltype);
        if hdlgetparameter('isvhdl')
            inputisslv=vhdlisstdlogicvector(in);
        else
            inputisslv=false;
        end

        outname=hdlsignalname(out);
        outvector=hdlsignalvector(out);
        outveclen=max(max(outvector,1));
        outcomplex=hdlsignaliscomplex(out);
        outvtype=hdlsignalvtype(out);
        outsltype=hdlsignalsltype(out);
        [outsize,outbp,outsigned]=hdlwordsize(outsltype);


        if nargin<=4||isempty(label)
            isloop=0;
            genlabel=[outname,hdlgetparameter('block_generate_label')];



        else
            isloop=0;
            genlabel=label;
        end


        assign_type_options={'real','imag','all'};
        if(nargin<6)||~strmatch(assign_type,assign_type_options)


            if(~incomplex&&outcomplex)
                assign_type='real';
            else
                assign_type='all';
            end
        end



        if(~incomplex&&~outcomplex)
            assign2=false;
            in1=in;
            out1=out;
        elseif(incomplex&&outcomplex)
            if strcmpi(assign_type,'all')


                assign2=true;
                in1=in;in2=hdlsignalimag(in);
                out1=out;out2=hdlsignalimag(out);
            elseif strcmpi(assign_type,'real')

                assign2=false;
                in1=in;
                out1=out;
            elseif strcmpi(assign_type,'imag')

                assign2=false;
                in1=hdlsignalimag(in);
                out1=hdlsignalimag(out);
            end
        elseif(incomplex&&~outcomplex)

            assign2=false;
            out1=out;
            if strcmpi(assign_type,'all')||strcmpi(assign_type,'real')

                in1=in;
            elseif strcmpi(assign_type,'imag')

                in1=hdlsignalimag(in);
            end
        elseif(~incomplex&&outcomplex)
            if strcmpi(assign_type,'all')

                assign2=true;
                in1=in;in2=in;
                out1=out;out2=hdlsignalimag(out);
            elseif strcmpi(assign_type,'real')

                assign2=false;
                in1=in;
                out1=out;
            elseif strcmpi(assign_type,'imag')

                assign2=false;
                in1=in;
                out1=hdlsignalimag(out);
            end
        end







        in1_name=hdlsignalname(in1);
        out1_name=hdlsignalname(out1);
        if(assign2)
            in2_name=hdlsignalname(in2);
            out2_name=hdlsignalname(out2);
        end

        hdlbody='';
        array_deref=hdlgetparameter('array_deref');
        if~(all(invector==0)&&all(outvector==0))
            if hdlgetparameter('loop_unrolling')==1
                for n=0:max(inveclen,outveclen)-1
                    if(inveclen==1&&inveclen~=outveclen)


                        inidx='';
                    else
                        inidx=[array_deref(1),num2str(rem(n,inveclen)),array_deref(2)];
                    end
                    if(outveclen==1&&outveclen~=inveclen)


                        outidx='';
                    else
                        outidx=[array_deref(1),num2str(rem(n,outveclen)),array_deref(2)];
                    end
                    hdlbody=[hdlbody...
                    ,datatypebit([in1_name,inidx],insize,inbp,insigned,...
                    invtype,inputisslv,...
                    [out1_name,outidx],outsize,outbp,outsigned,outvtype,...
                    rounding,saturation,assign_prefix,assign_op)];
                    if(assign2)
                        hdlbody=[hdlbody...
                        ,datatypebit([in2_name,inidx],insize,inbp,insigned,...
                        invtype,inputisslv,...
                        [out2_name,outidx],outsize,outbp,outsigned,outvtype,...
                        rounding,saturation,assign_prefix,assign_op)];
                    end
                end
                hdlbody=[hdlbody,'\n'];
            else


                loopcount=num2str(max(inveclen,outveclen)-1);
                if isloop
                    hdlbody=['  FOR k IN 0 TO ',loopcount,' LOOP\n'];
                else
                    hdlbody=['  ',genlabel,':FOR k IN 0 TO ',loopcount,' GENERATE\n'];
                end

                if(inveclen==outveclen)
                    inidx='(k)';
                else
                    inidx='';
                end
                outidx='(k)';
                hdlbody=[hdlbody,'  '...
                ,datatypebit([in1_name,inidx],insize,inbp,insigned,...
                invtype,inputisslv,...
                [out1_name,outidx],outsize,outbp,outsigned,outvtype,...
                rounding,saturation,assign_prefix,assign_op)];

                if assign2
                    hdlbody=[hdlbody,'  '...
                    ,datatypebit([in2_name,inidx],insize,inbp,...
                    insigned,invtype,inputisslv,...
                    [out2_name,outidx],outsize,outbp,outsigned,...
                    outvtype,...
                    rounding,saturation,assign_prefix,assign_op)];
                end

                if isloop
                    hdlbody=[hdlbody,'  END LOOP;\n\n'];
                else
                    hdlbody=[hdlbody,'  END GENERATE;\n\n'];
                end
            end
        else
            hdlbody=[hdlbody...
            ,datatypebit(in1_name,insize,inbp,insigned,invtype,inputisslv,...
            out1_name,outsize,outbp,outsigned,outvtype,...
            rounding,saturation,assign_prefix,assign_op)];
            if assign2
                hdlbody=[hdlbody...
                ,datatypebit(in2_name,insize,inbp,insigned,invtype,...
                inputisslv,...
                out2_name,outsize,outbp,outsigned,outvtype,...
                rounding,saturation,assign_prefix,assign_op)];
            end

            hdlbody=[hdlbody,'\n'];
        end



        if gConnOld,
            hCD=hdlconnectivity.getConnectivityDirector;
            rhs_pattern=[assign_op,'\s+(.*?);'];
            rhs=regexp(hdlbody,rhs_pattern,'tokens');
            if~isempty(rhs);

                if~isempty(rhs{1}{1})
                    if~isempty(regexp(rhs{1}{1},regexptranslate('escape',in1_name),'once')),


                        if inveclen==1||inveclen==0,

                            if outveclen==1||outveclen==0,
                                rindex={[]};
                                dindex={[]};
                            else
                                rindex=num2cell(0:(outveclen-1));
                                dindex=cell(1,outveclen);
                            end

                        else
                            dindex=num2cell(0:(min(inveclen,outveclen)-1));
                            rindex=num2cell(0:(min(inveclen,outveclen)-1));
                        end




                        for ii=1:numel(dindex),
                            hCD.addDriverReceiverPair(in1,out1,'realonly',true,'unroll',false,...
                            'driverIndices',dindex{ii},'receiverIndices',rindex{ii});
                        end

                        if assign2,
                            for ii=1:numel(dindex);
                                hCD.addDriverReceiverPair(in2,out2,'realonly',true,...
                                'driverIndices',dindex{ii},'receiverIndices',rindex{ii});
                            end
                        end

                    end
                end
            end
        end




        hdlconnectivity.genConnectivity(gConnOld);
    end


    function[begstr,endstr]=hdltoreal
        if hdlgetparameter('isvhdl')
            begstr='REAL(TO_INTEGER(';
            endstr='))';
        else
            begstr='$itor(';
            endstr=')';
        end


        function[begstr,endstr]=hdlfromreal(outsize,outbp,outsigned)
            if hdlgetparameter('isvhdl')
                lang='VHDL';
                if outsigned
                    begstr='TO_SIGNED(INTEGER(';
                else
                    begstr='TO_UNSIGNED(INTEGER(';
                end
                if(outbp<0)
                    endstr=['/(2.0**',num2str(-1*outbp),')','), ',num2str(outsize),')'];
                else
                    endstr=['*(2.0**',num2str(outbp),')','), ',num2str(outsize),')'];
                end
            else
                begstr='$rtoi(';
                if(outbp<0)
                    endstr=['/(2**',num2str(-1*outbp),'))'];
                else
                    endstr=[' * (2**',num2str(outbp),'))'];
                end
                lang='Verilog';
            end

            if(outbp>31)



                warning(message('HDLShared:directemit:HDLIntegerOverflow'));
            end




            function hdlbody=datatypebit(inname,insize,inbp,insigned,invtype,inputisslv,...
                outname,outsize,outbp,outsigned,outvtype,...
                rounding,saturation,assign_prefix,assign_op)

                if outsize==0&&insize==0
                    [inname,insize]=hdlsignaltypeconvert(inname,insize,insigned,invtype,0);
                    hdlbody=['  ',assign_prefix,outname,...
                    ' ',assign_op,' ',inname,';\n\n'];

                elseif outsize==0
                    [st,ts]=hdltoreal;

                    [inname,insize]=hdlsignaltypeconvert(inname,insize,insigned,invtype,1);
                    if hdlgetparameter('isvhdl')
                        if(inbp<0)
                            hdlbody=['  ',assign_prefix,outname,...
                            ' ',assign_op,' ',st,inname,ts,'*(2.0**',num2str(-1*inbp),')',';\n\n'];
                        else
                            hdlbody=['  ',assign_prefix,outname,...
                            ' ',assign_op,' ',st,inname,ts,'/(2.0**',num2str(inbp),')',';\n\n'];
                        end
                    else
                        if(~insigned)
                            if(inbp<0)
                                hdlbody=['  ',assign_prefix,outname,...
                                ' ',assign_op,' (',inname,ts,'*(2**',num2str(-1*inbp),');\n'];
                            else
                                hdlbody=['  ',assign_prefix,outname,...
                                ' ',assign_op,' (',inname,ts,'/(2**',num2str(inbp),');\n'];
                            end
                        else
                            if(insize>2)
                                ip_sign_bit=[inname,'[',num2str(insize-1),']'];
                                ip_no_sign_bit=[inname,'[',num2str(insize-2),':0]'];
                            else
                                ip_sign_bit=inname;
                                ip_no_sign_bit=inname;
                            end

                            if(insize>inbp)
                                lval_base2=insize-inbp-1;
                            else
                                lval_base2=0;
                            end


                            if(inbp<0)
                                bp_hdlbody=['*(2**',num2str(-1*inbp),')'];
                            else
                                bp_hdlbody=['/(2**',num2str(inbp),')'];
                            end


                            hdlbody=['  ',assign_prefix,outname,...
                            ' ',assign_op,' (',st,ip_no_sign_bit,ts,bp_hdlbody,') - ',...
                            '((2**',num2str(lval_base2),') * ',ip_sign_bit,');\n'];
                        end
                    end

                elseif insize==0
                    [st,ts]=hdlfromreal(outsize,outbp,outsigned);
                    [inname,insize]=hdlsignaltypeconvert(inname,insize,insigned,invtype,0);
                    hdlbody=['  ',assign_prefix,outname,...
                    ' ',assign_op,' ',st,inname,ts,';\n\n'];

                else
                    if insize==1
                        [inname,insize]=hdlsignaltypeconvert(inname,insize,insigned,invtype,0,inputisslv);
                    else
                        [inname,insize]=hdlsignaltypeconvert(inname,insize,insigned,invtype,outsigned,inputisslv);
                    end

                    if hdlgetparameter('isvhdl')&&insize==1&&outsize~=1
                        inname=['"0" & ',inname];
                    end

                    if inputisslv

                        invtype=hdlgetporttypesfromsizes(insize,inbp,insigned);
                    end

                    final_result=hdltypeconvert(inname,insize,inbp,insigned,invtype,...
                    outsize,outbp,outsigned,outvtype,...
                    rounding,saturation);

                    hdlbody=['  ',assign_prefix,outname,...
                    ' ',assign_op,' ',final_result,';\n'];

                end



