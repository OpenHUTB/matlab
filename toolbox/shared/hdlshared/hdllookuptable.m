function[hdlbody,hdlsignals,hdlconstants]=hdllookuptable(in,out,intable,outtable,rounding,sat)













    narginchk(4,6);

    if nargin<5
        rounding='floor';
        sat=0;
    elseif nargin<6
        sat=0;
    end


    gConnOld=hdlconnectivity.genConnectivity(0);
    if gConnOld,
        hConnDir=hdlconnectivity.getConnectivityDirector;
        hConnDir.addDriverReceiverPair(in,out,'realonly',true);
        if hdlsignaliscomplex(out),
            hConnDir.addDriverReceiverPair(in,hdlsignalimag(out),'realonly',true);
        end
    end


    [hdlbody,hdlsignals,hdlconstants]=reallookuptable(in,out,intable,real(outtable),rounding,sat);
    if hdlsignaliscomplex(out),
        [hdlbodytmp,hdlsignalstmp,hdlconstantstmp]=reallookuptable(in,hdlsignalimag(out),...
        intable,imag(outtable),rounding,sat);

        hdlbody=[hdlbody,hdlbodytmp];
        hdlsignals=[hdlsignals,hdlsignalstmp];
        hdlconstants=[hdlconstants,hdlconstantstmp];
    end



    hdlconnectivity.genConnectivity(gConnOld);





    function[hdlbody,hdlsignals,hdlconstants]=reallookuptable(in,out,intable,outtable,rounding,sat)
        if sat
            overflowmode='saturate';
        else
            overflowmode='wrap';
        end

        hdlbody='';
        hdlsignals='';
        hdlconstants='';

        inname=hdlsignalname(in);
        insltype=hdlsignalsltype(in);
        [insize,inbp,insigned]=hdlwordsize(insltype);

        invtype=hdlsignalvtype(in);
        [casename,insize]=hdlsignaltypeconvert(inname,insize,insigned,invtype,insigned);

        outname=hdlsignalname(out);

        outvector=hdlsignalvector(out);
        outsltype=hdlsignalsltype(out);
        [outsize,outbp,outsigned]=hdlwordsize(outsltype);




        intablesize=length(intable);
        outtablesize=length(outtable);

        if insize==0
            error(message('HDLShared:directemit:floatnotallowed'));
        end

        if intablesize~=outtablesize
            error(message('HDLShared:directemit:mustbesamesize',intablesize,outtablesize));
        end


        maxsize=2.^20;
        if(intablesize>maxsize)
            error(message('HDLShared:directemit:maxtablesize',maxsize));
        end

        if(insize~=1)&&(intablesize>2.^insize)
            error(message('HDLShared:directemit:maxwidth',intablesize,insize));
        end

        if outvector~=0
            error(message('HDLShared:directemit:novectors'));
        end



        firounding=localmaproundingmodes(rounding);

        infi=fi(intable(:),insigned,insize,inbp,'RoundMode',firounding,'OverflowMode',overflowmode);
        outfi=fi(outtable(:),outsigned,outsize,outbp,'RoundMode',firounding,'OverflowMode',overflowmode);


        if hdlgetparameter('isvhdl')

            if insize==1
                inquote='''';
            else
                inquote='"';
            end

            if outsize==1
                outquote='''';
            else
                outquote='"';
            end


            hdlbody=[hdlbody,'  PROCESS(',inname,')\n',...
            '  BEGIN\n',...
            '    CASE ',casename,' IS\n'];
            if length(infi)==2
                casebody=strcat({'      WHEN '},inquote,bin(infi),inquote,{' => '},...
                {outname},{' <= '},outquote,bin(outfi),outquote,{';\n'});
            else
                casebody=strcat({'      WHEN '},inquote,bin(infi),inquote,{' => '},...
                {outname},{' <= '},outquote,bin(outfi),outquote,{';\n'});
            end
            hdlbody=[hdlbody,casebody{:}];
            hdlbody=[hdlbody,'      WHEN OTHERS => ',outname,' <= ',outquote,bin(outfi(end)),outquote,';\n'];
            hdlbody=[hdlbody,'    END CASE;\n'];






            hdlbody=[hdlbody,'  END PROCESS;\n'];
        elseif hdlgetparameter('isverilog')
            hdlbody=[hdlbody,'  always @(',inname,')\n',...
            '  begin\n',...
            '    case(',casename,')\n'];

            casebody=strcat({'      '},{sprintf('%d''b',insize)},bin(infi),{' : '},...
            outname,{' = '},{sprintf('%d''b',outsize)},bin(outfi),{';\n'});
            hdlbody=[hdlbody,casebody{:}];
            hdlbody=[hdlbody,'      default : ',outname,' = ',...
            sprintf('%d''b',outsize),bin(outfi(end)),';\n'];
            hdlbody=[hdlbody,'    endcase\n'];





            hdlbody=[hdlbody,'  end\n'];
            hdlregsignal(out);

        else
            error(message('HDLShared:directemit:UnknownTargetLanguage',hdlgetparameter('target_language')));
        end

        hdlbody=[hdlbody,'\n'];


        function rnd=localmaproundingmodes(rnd)




            switch lower(rnd)
            case 'simplest'
                error(message('HDLShared:directemit:simplestunsupported'));
            case 'ceiling'
                rnd='ceil';
            case 'zero'
                rnd='fix';
            end


