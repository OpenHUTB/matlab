function[hdlbody,hdlsignals]=hdlunaryminus(in,out,rounding,saturation,realonly)




















    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    hdlbody='';
    hdlsignals='';

    if~emitMode
        pirelab.getUnaryMinusComp(hN,in,out,saturation);
    else
        if nargin<5,
            realonly=false;
        end


        [hdlbodytmp,hdlsignalstmp]=unaryminus_realpart(in,out,rounding,saturation);
        hdlbody=[hdlbody,hdlbodytmp];
        hdlsignals=[hdlsignals,hdlsignalstmp];


        if~(realonly)&&hdlsignaliscomplex(out)&&hdlsignaliscomplex(in),
            [hdlbodytmp,hdlsignalstmp]=unaryminus_realpart(hdlsignalimag(in),hdlsignalimag(out),...
            rounding,saturation);
            hdlbody=[hdlbody,hdlbodytmp];
            hdlsignals=[hdlsignals,hdlsignalstmp];
        end
    end


    function[hdlbody,hdlsignals]=unaryminus_realpart(in,out,rounding,saturation);


        [assign_prefix,assign_op]=hdlassignforoutput(out);
        comment_char=hdlgetparameter('comment_char');

        inname=hdlsignalname(in);
        inhandle=hdlsignalhandle(in);
        invector=hdlsignalvector(in);
        invtype=hdlsignalvtype(in);
        insltype=hdlsignalsltype(in);
        [insize,inbp,insigned]=hdlwordsize(insltype);

        outname=hdlsignalname(out);
        outhandle=hdlsignalhandle(out);
        outvector=hdlsignalvector(out);
        outvtype=hdlsignalvtype(out);
        outsltype=hdlsignalsltype(out);
        [outsize,outbp,outsigned]=hdlwordsize(outsltype);

        hdlsignals='';



        if outsize==0
            hdlbody=['  ',assign_prefix,outname,' ',assign_op,' -',inname,';\n\n'];


            resourceLog(0,0,'sub');

        elseif outsize==1
            [inname,insize]=hdlsignaltypeconvert(inname,insize,insigned,invtype,0);
            if hdlgetparameter('isvhdl')
                hdlbody=['  ',assign_prefix,outname,' ',assign_op,' ''1'' WHEN ',...
                inname,' = 0 ELSE ''0'';\n\n'];
            elseif hdlgetparameter('isverilog')
                hdlbody=['  ',assign_prefix,outname,' ',assign_op,' (',iname,') ? 1''b1 : 1''b0'];
            end


            resourceLog(2,outsize,'mux');

        elseif(outsigned==1&&insigned==0&&outsize==insize+1)



            if hdlgetparameter('isvhdl')
                hdlbody=['  ',assign_prefix,outname,' ',assign_op,' ',...
                '-resize(',inname,',',num2str(outsize),');\n'];
            elseif hdlgetparameter('isverilog')
                hdlbody=['  ',assign_prefix,outname,' ',assign_op,' ',...
                ' -',inname,';\n'];
            end


            resourceLog(outsize,outsize,'sub');

        else
            [inname,newsize]=hdlsignaltypeconvert(inname,insize,insigned,invtype,outsigned);

            if~(outsize==newsize+1&&inbp==outbp&&insigned==outsigned)

                if(insigned~=outsigned)
                    tempsigned=1;
                else
                    tempsigned=insigned;
                end

                [tempvtype,tempsltype]=hdlgettypesfromsizes(newsize+1,inbp,tempsigned);
                [tempname,temploc]=hdlnewsignal('unaryminus_temp','block',-1,0,0,...
                tempvtype,tempsltype);
                hdlsignals=makehdlsignaldecl(temploc);
                skip_final=false;
            else
                tempname=outname;
                temploc=out;
                tempvtype=outvtype;
                tempsltype=outsltype;
                skip_final=true;
            end


            if hdlgetparameter('isvhdl')
                minusconst=['"1','0'*ones(1,insize-1),'"'];

                hdlbody=['  ',assign_prefix,tempname,' ',assign_op,' ',...
                '(''0'' & ',inname,') WHEN ',inname,' = ',...
                minusconst,'\n',...
                '      ELSE ','-resize(',inname,',',num2str(newsize+1),');\n'];
            elseif hdlgetparameter('isverilog')
                minusconst=hdlconstantvalue(-inf,insize,0,1);
                extinname=['{1''b0, ',inname,'}'];
                if outsigned
                    extinname=['$signed(',extinname,')'];
                end
                hdlbody=['  ',assign_prefix,tempname,' ',assign_op,' ',...
                '(',inname,'==',minusconst,') ? ',...
                extinname,' : -',inname,';\n'];

            end
            if skip_final
                hdlbody=[hdlbody,'\n'];
            else
                hdlbody=[hdlbody,hdldatatypeassignment(temploc,out,rounding,saturation,[],'real')];
            end


            [tempsize,~,~]=hdlwordsize(tempsltype);
            resourceLog(2,tempsize,'mux');
            resourceLog(tempsize,tempsize,'sub');

        end



        if hdlconnectivity.genConnectivity,
            hConnDir=hdlconnectivity.getConnectivityDirector;

            if exist('temploc')==1,
                rcvr=temploc;
            else
                rcvr=out;
            end

            hConnDir.addDriverReceiverPair(in,rcvr,'realonly',true);
        end






