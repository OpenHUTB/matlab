function[body,signals]=hdlonebitaddsub(in1,in2,out,rounding,saturation,operation,bittrue)
















    [outsize,outbp,outsigned]=hdlwordsize(hdlsignalsltype(out));


    Fm=fimath;
    if strcmpi(rounding,'Ceiling'),
        Fm.RoundMode='ceil';
    elseif strcmpi(rounding,'Zero'),
        Fm.RoundMode='fix';
    else
        Fm.RoundMode=rounding;
    end

    if saturation,
        Fm.OverflowMode='Saturate';
    else
        Fm.OverflowMode='Wrap';
    end
    Fm.CastBeforeSum=bittrue;


    if outsize==1,
        [body,signals]=out_onebitaddsub(in1,in2,out,rounding,saturation,operation,bittrue,Fm);
    else
        [body,signals]=in_onebitaddsub(in1,in2,out,rounding,saturation,operation,bittrue,Fm);
    end








    function[body,signals]=in_onebitaddsub(in1,in2,out,rounding,saturation,operation,bittrue,Fm)

        body='';
        signals='';


        name1=hdlsignalname(in1);
        vtype1=hdlsignalvtype(in1);
        sltype1=hdlsignalsltype(in1);
        [size1,bp1,signed1]=hdlwordsize(sltype1);

        name2=hdlsignalname(in2);
        vtype2=hdlsignalvtype(in2);
        sltype2=hdlsignalsltype(in2);
        [size2,bp2,signed2]=hdlwordsize(sltype2);

        outname=hdlsignalname(out);
        outvtype=hdlsignalvtype(out);
        outsltype=hdlsignalsltype(out);
        [outsize,outbp,outsigned]=hdlwordsize(outsltype);

        if signed1==0&&signed2==0&&outsigned==0
            resultsigned=0;
        else
            resultsigned=1;
        end


        if~bittrue,


            if bp1>bp2
                s2=size2+(bp1-bp2);
                s1=size1;
                sumbp=bp1;
            elseif bp1<bp2
                s1=size1+(bp2-bp1);
                s2=size2;
                sumbp=bp2;
            else
                s1=size1;
                s2=size2;
                sumbp=bp1;
            end
            sumsize=1+max(s1,s2);
            sumsigned=resultsigned;
        else
            sumsize=outsize+1;
            sumbp=outbp;
            sumsigned=resultsigned;
        end
        Fm.SumWordLength=sumsize;
        Fm.SumFractionLength=sumbp;
        [sumvtype,sumsltype]=hdlgettypesfromsizes(sumsize,sumbp,resultsigned);









        in1fimax=fi(0,0,1,bp1,Fm);in1fimax.bin(1:end)='1';
        in2fimax=fi(0,0,1,bp2,Fm);in2fimax.bin(1:end)='1';
        fiout=fi(0,outsigned,outsize,outbp,Fm);
        fisum=fi(0,sumsigned,sumsize,sumbp,Fm);

        lutvalues=fi(0,outsigned,outsize,outbp,Fm);


        if Fm.CastBeforeSum,
            fiout(1)=in1fimax;
            fiout(2)=in2fimax;
            fisum(1)=fiout(1);
            fisum(2)=fiout(2);

            lutvalues(2)=eval([operation{1},'fiout(1)']);
            lutvalues(3)=eval([operation{2},'fiout(2)']);
            lutvalues(4)=eval([operation{1},'fiout(1)',operation{2},' fiout(2)']);

        else
            fisum(1)=in1fimax;
            fisum(2)=in2fimax;
            fiout(1)=fisum(1);
            fiout(2)=fisum(2);

            lutvalues(2)=eval([operation{1},'fisum(1)']);
            lutvalues(3)=eval([operation{2},'fisum(2)']);
            lutvalues(4)=eval([operation{1},'fisum(1)',operation{2},' fisum(2)']);

        end




        if size1==1&&size2==1,


            if all(lutvalues==0),
                body=getfield(hdl.constantassign(out,0,[],'real'),'arch_body_blocks');

            elseif lutvalues(3)==0&&lutvalues(2)==lutvalues(4),
                body=makelut(out,{name1},lutvalues(1:2));


                if hdlconnectivity.genConnectivity,
                    hConnDir=hdlconnectivity.getConnectivityDirector;
                    hConnDir.addDriverReceiverPair(in1,out,'realonly',true);
                end


            elseif lutvalues(2)==0&&lutvalues(3)==lutvalues(4),
                body=makelut(out,{name2},[lutvalues(1),lutvalues(3)]);


                if hdlconnectivity.genConnectivity,
                    hConnDir=hdlconnectivity.getConnectivityDirector;
                    hConnDir.addDriverReceiverPair(in2,out,'realonly',true);
                end



            else
                body=makelut(out,{name1,name2},lutvalues);


                if hdlconnectivity.genConnectivity,
                    hConnDir=hdlconnectivity.getConnectivityDirector;
                    hConnDir.addDriverReceiverPair(in1,out,'realonly',true);
                    hConnDir.addDriverReceiverPair(in2,out,'realonly',true);
                end



            end

        elseif size1==1,



            if fisum(1)~=0,
                [sumname,sumidx]=hdlnewsignal('add_temp','block',-1,0,0,sumvtype,sumsltype);
                signals=[signals,makehdlsignaldecl(sumidx)];

                if bittrue,
                    [addtmpname,addtmpidx]=hdlnewsignal('add_cast','block',-1,0,0,outvtype,outsltype);
                    signals=[signals,makehdlsignaldecl(addtmpidx)];

                    body=[body,hdldatatypeassignment(in2,addtmpidx,rounding,saturation)];
                    addin=hdltypeconvert(addtmpname,outsize,outbp,outsigned,outvtype,sumsize,sumbp,...
                    sumsigned,sumvtype,rounding,saturation);





                    if hdlconnectivity.genConnectivity,
                        hConnDir=hdlconnectivity.getConnectivityDirector;


                        satin=regexptranslate('escape',addtmpname);
                        if~isempty(regexp(addin,satin,'once')),
                            hConnDir.addDriverReceiverPair(addtmpidx,out,'realonly',true);
                        end
                        hConnDir.addDriverReceiverPair(in1,out,'realonly',true);
                    end



                else

                    [name2,size2]=hdlsignaltypeconvert(name2,size2,signed2,vtype2,outsigned);
                    addin=hdltypeconvert(name2,size2,bp2,signed2,vtype2,sumsize,sumbp,...
                    sumsigned,sumvtype,'floor',false);





                    if hdlconnectivity.genConnectivity,
                        hConnDir=hdlconnectivity.getConnectivityDirector;


                        satin=regexptranslate('escape',name2);
                        if~isempty(regexp(addin,satin,'once')),
                            hConnDir.addDriverReceiverPair(in2,out,'realonly',true);
                        end

                        hConnDir.addDriverReceiverPair(in1,out,'realonly',true);
                    end


                end

                body=[body,makemuxinc(sumidx,addin,fisum(1),name1,fliplr(operation)),...
                hdldatatypeassignment(sumidx,out,rounding,saturation,[],'real')];
            else
                if strcmpi(operation{2},'-'),
                    [sumname,sumidx]=hdlnewsignal('add_temp','block',-1,0,0,outvtype,outsltype);
                    signals=[signals,makehdlsignaldecl(sumidx)];

                    body=[hdldatatypeassignment(in2,sumidx,rounding,saturation,[],'real'),...
                    hdlunaryminus(sumidx,out,rounding,saturation,true)];
                else
                    body=[hdldatatypeassignment(in2,out,rounding,saturation,[],'real')];
                end
            end

        else

            if fisum(2)~=0,




                [sumname,sumidx]=hdlnewsignal('add_temp','block',-1,0,0,sumvtype,sumsltype);
                signals=[signals,makehdlsignaldecl(sumidx)];
                if bittrue,
                    [addtmpname,addtmpidx]=hdlnewsignal('add_cast','block',-1,0,0,outvtype,outsltype);
                    signals=[signals,makehdlsignaldecl(addtmpidx)];

                    body=[body,hdldatatypeassignment(in1,addtmpidx,rounding,saturation)];
                    addin=hdltypeconvert(addtmpname,outsize,outbp,outsigned,outvtype,sumsize,sumbp,...
                    sumsigned,sumvtype,rounding,saturation);





                    if hdlconnectivity.genConnectivity,
                        hConnDir=hdlconnectivity.getConnectivityDirector;


                        satin=regexptranslate('escape',addtmpname);
                        if~isempty(regexp(addin,satin,'once')),
                            hConnDir.addDriverReceiverPair(addtmpidx,out,'realonly',true);
                        end
                        hConnDir.addDriverReceiverPair(in2,out,'realonly',true);
                    end

                else
                    [name1,size1]=hdlsignaltypeconvert(name1,size1,signed1,vtype1,outsigned);
                    addin=hdltypeconvert(name1,size1,bp1,signed1,vtype1,sumsize,sumbp,...
                    sumsigned,sumvtype,'floor',false);





                    if hdlconnectivity.genConnectivity,
                        hConnDir=hdlconnectivity.getConnectivityDirector;


                        satin=regexptranslate('escape',name1);
                        if~isempty(regexp(addin,satin,'once')),
                            hConnDir.addDriverReceiverPair(in1,out,'realonly',true);
                        end

                        hConnDir.addDriverReceiverPair(in2,out,'realonly',true);
                    end


                end
                body=[body,makemuxinc(sumidx,addin,fisum(2),name2,operation),...
                hdldatatypeassignment(sumidx,out,rounding,saturation,[],'real')];
            else




                if strcmpi(operation{1},'-'),
                    [sumname,sumidx]=hdlnewsignal('add_temp','block',-1,0,0,outvtype,outsltype);
                    signals=[signals,makehdlsignaldecl(sumidx)];

                    body=[hdldatatypeassignment(in1,sumidx,rounding,saturation,[],'real'),...
                    hdlunaryminus(sumidx,out,rounding,saturation,true)];
                else
                    body=[hdldatatypeassignment(in1,out,rounding,saturation,[],'real')];
                end
            end

        end






        function body=makemuxinc(out,inname,incfi,sel,operation)
            [sumWL,sumBP,sumSIGN]=hdlwordsize(hdlsignalsltype(out));
            inc_const=hdlconstantvalue(incfi,sumWL,sumBP,sumSIGN);

            [assign_prefix,assign_op]=hdlassignforoutput(out);

            if strcmpi(inc_const,'''1'''),
                inc_const='1';
            elseif strcmpi(inc_const,'''0'''),
                inc_const='0';
            end

            op1=operation{1};
            op2=operation{2};

            op1=strrep(op1,'+','');
            if strcmpi(op2,''),
                op2='+';
            end

            if hdlgetparameter('isvhdl'),
                assign_begin=['  ',hdlsignalname(out),' <= '];
                ind=repmat(' ',1,length(assign_begin));
                body=[assign_begin,op1,inname,' ',op2,' ',inc_const,' WHEN ',...
                sel,' = ''1'' ELSE\n',ind,op1,inname,';\n\n'];

            else
                assign_begin=['  ',assign_prefix,hdlsignalname(out),' ',assign_op];
                ind=repmat(' ',1,length(assign_begin));
                body=[assign_begin,' (',sel,' == 1)? ',...
                op1,inname,' ',op2,' ',inc_const,' :\n',ind,' ',op1,inname,';\n\n'];

            end



            function body=makelut(out,inname,lutvals)

                [sumWL,sumBP,sumSIGN]=hdlwordsize(hdlsignalsltype(out));

                for ii=1:length(lutvals),
                    const{ii}=hdlconstantvalue(lutvals(ii),sumWL,sumBP,sumSIGN);
                end

                [assign_prefix,assign_op]=hdlassignforoutput(out);


                outname=hdlsignalname(out);
                if hdlgetparameter('isvhdl')
                    assign_begin=['  ',outname,' <= '];
                    ind=repmat(' ',1,length(assign_begin));
                    if length(inname)==1,
                        body=[assign_begin,...
                        const{1},' WHEN ',inname{1},' = ''0'' ELSE\n',...
                        ind,const{2},';\n\n'];
                    else
                        body=[assign_begin,...
                        const{1},' WHEN ',inname{1},' = ''0'' AND ',inname{2},' = ''0'' ELSE\n',...
                        ind,const{2},' WHEN ',inname{1},' = ''1'' AND ',inname{2},' = ''0'' ELSE\n',...
                        ind,const{3},' WHEN ',inname{1},' = ''0'' AND ',inname{2},' = ''1'' ELSE\n',...
                        ind,const{4},';\n\n'];
                    end
                else
                    assign_begin=['  ',assign_prefix,outname,' ',assign_op,' '];
                    ind=repmat(' ',1,length(assign_begin));
                    if length(inname)==1,
                        body=[assign_begin,'(',inname{1},' == 1''b0) ? ',const{1},' :\n',...
                        ind,const{2},';\n\n'];

                    else
                        body=[assign_begin,'(',inname{1},' == 1''b0 & ',inname{2},' == 1''b0 ) ? ',const{1},' :\n',...
                        ind,'(',inname{1},' == 1''b1 & ',inname{2},' == 1''b0 ) ? ',const{2},' :\n',...
                        ind,'(',inname{1},' == 1''b0 & ',inname{2},' == 1''b1 ) ? ',const{3},' :\n',...
                        ind,const{4},';\n\n'];
                    end
                end





                function[body,signals]=out_onebitaddsub(in1,in2,out,rounding,saturation,operation,bittrue,Fm)

                    signals='';
                    body='';
                    name1=hdlsignalname(in1);
                    vtype1=hdlsignalvtype(in1);
                    sltype1=hdlsignalsltype(in1);
                    [size1,bp1,signed1]=hdlwordsize(sltype1);

                    name2=hdlsignalname(in2);
                    vtype2=hdlsignalvtype(in2);
                    sltype2=hdlsignalsltype(in2);
                    [size2,bp2,signed2]=hdlwordsize(sltype2);

                    outname=hdlsignalname(out);
                    outvtype=hdlsignalvtype(out);
                    outsltype=hdlsignalsltype(out);
                    [outsize,outbp,outsigned]=hdlwordsize(outsltype);


                    [assign_prefix,assign_op]=hdlassignforoutput(out);

                    if bittrue,

                        if strcmpi(operation{1},'-')&&strcmpi(operation{2},'-')&&saturation,

                            body=getfield(hdl.constantassign(out,0,[],'real'),'arch_body_blocks');

                        else

                            [in1castname,in1cast]=hdlnewsignal('add_cast','block',-1,0,0,outvtype,outsltype);
                            [in2castname,in2cast]=hdlnewsignal('add_cast','block',-1,0,0,outvtype,outsltype);
                            signals=[signals,makehdlsignaldecl(in1cast),makehdlsignaldecl(in2cast)];
                            body=[body,hdldatatypeassignment(in1,in1cast,rounding,saturation,[],'real')];
                            body=[body,hdldatatypeassignment(in2,in2cast,rounding,saturation,[],'real')];


                            if saturation,

                                if strcmpi(operation{2},'+')
                                    body=[body,hdlbitop([in1cast,in2cast],out,'OR')];
                                else
                                    if hdlgetparameter('isvhdl'),
                                        body=[body,'  ',hdlsignalname(out),' <= ',in1castname,' AND NOT(',in2castname,');\n\n'];
                                    else
                                        body=[body,'  ',assign_prefix,outname,' ',assign_op,' ',...
                                        in1castname,' & ~(',in2castname,');\n\n'];
                                    end
                                end
                            else
                                body=[body,hdlbitop([in1cast,in2cast],out,'XOR')];
                            end



                            if hdlconnectivity.genConnectivity,
                                hConnDir=hdlconnectivity.getConnectivityDirector;
                                hConnDir.addDriverReceiverPair(in1cast,out,'realonly',true);
                                hConnDir.addDriverReceiverPair(in2cast,out,'realonly',true);
                            end



                        end
                    else


                        if bp1>bp2
                            s2=size2+(bp1-bp2);
                            s1=size1;
                            sumbp=bp1;
                        elseif bp1<bp2
                            s1=size1+(bp2-bp1);
                            s2=size2;
                            sumbp=bp2;
                        else
                            s1=size1;
                            s2=size2;
                            sumbp=bp1;

                        end
                        if signed1==0&&signed2==0&&outsigned==0
                            resultsigned=0;
                        else
                            resultsigned=1;
                        end
                        sumsize=1+max(s1,s2);
                        [sumvtype,sumsltype]=hdlgettypesfromsizes(sumsize,sumbp,resultsigned);
                        [sumname,sumidx]=hdlnewsignal('add_temp','block',-1,0,0,sumvtype,sumsltype);
                        [in1castname,in1cast]=hdlnewsignal('add_cast','block',-1,0,0,sumvtype,sumsltype);
                        [in2castname,in2cast]=hdlnewsignal('add_cast','block',-1,0,0,sumvtype,sumsltype);
                        signals=[signals,makehdlsignaldecl(sumidx),makehdlsignaldecl(in1cast),makehdlsignaldecl(in2cast)];

                        body=[body,hdldatatypeassignment(in1,in1cast,rounding,saturation,[],'real')];
                        body=[body,hdldatatypeassignment(in2,in2cast,rounding,saturation,[],'real')];


                        op1=operation{1};
                        op2=operation{2};
                        op1=strrep(op1,'+','');
                        if strcmpi(op2,''),
                            op2='+';
                        end
                        [assign_prefix,assign_op]=hdlassignforoutput(out);
                        if hdlgetparameter('isvhdl')
                            body=[body,'  ',sumname,' <= ',op1,in1castname,' ',op2,' ',in2castname,';\n'];
                        else
                            body=[body,'  ',assign_prefix,sumname,' ',assign_op,' ',...
                            op1,in1castname,' ',op2,' ',in2castname,';\n'];
                        end
                        body=[body,hdldatatypeassignment(sumidx,out,rounding,saturation,[],'real')];



                        if hdlconnectivity.genConnectivity,
                            hConnDir=hdlconnectivity.getConnectivityDirector;
                            hConnDir.addDriverReceiverPair(in1cast,sumidx,'realonly',true);
                            hConnDir.addDriverReceiverPair(in2cast,sumidx,'realonly',true);
                        end






                    end

