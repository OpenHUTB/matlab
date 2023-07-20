function[hdlbody,hdlsignals]=hdlmultiplyfactoredcsd(in,coeff,coeffptr,out,...
    rounding,saturation,pipelinedepth)





    if nargin==6||isempty(pipelinedepth)
        pipelinedepth=0;
    end

    if pipelinedepth==0
        mustpipeline=false;
    else
        mustpipeline=true;
    end

    hdlbody='';
    hdlsignals='';

    inname=hdlsignalname(in);
    insltype=hdlsignalsltype(in);
    [insize,inbp,insigned]=hdlwordsize(insltype);

    coeffsltype=hdlsignalsltype(coeffptr);
    [coeffsize,coeffbp,coeffsigned]=hdlwordsize(coeffsltype);

    outvtype=hdlsignalvtype(out);
    outsltype=hdlsignalsltype(out);

    if insize==0
        error(message('HDLShared:directemit:realinput','hdlmultiplyfactoredcsd',inname));
    elseif insize==1
        error(message('HDLShared:directemit:booleaninputfcsd',inname));
    elseif coeffsize>32
        error(message('HDLShared:directemit:inputtoolarge',inname));
    elseif coeff==0
        error(message('HDLShared:directemit:zeroinput',inname));
    end

    if insigned==0&&coeffsigned==0
        resultsigned=0;
    else
        resultsigned=1;
    end

    if coeff==1
        hdlbody=hdldatatypeassignment(in,out,rounding,saturation);
    else

        ival=floor(coeff*2^coeffbp+0.5);
        ivallog2=hdl.ceillog2(ival);
        finalsize=insize+ivallog2;
        [ivalfactors,ineg,factorlength,finalpowerof2]=hdl.csdfactors(ival);

        lastsize=insize;
        lastbp=inbp;
        lastsignal=in;

        nadd_csd=sum(hdl.csdrecode(ival,coeffsize)~=0)-1;
        nadd_fcsd=0;
        for ii=1:factorlength
            nadd_fcsd=nadd_fcsd+sum(hdl.csdrecode(ivalfactors(ii),coeffsize)~=0)-1;
        end

        if length(ivalfactors)==1||...
            hdl.ispowerof2(ival)||...
            ival==(2^ivallog2-1)||...
            ival==(2^(ivallog2-1)+1)||...
            nadd_fcsd>=nadd_csd

            hdlbody=[hdlbody,hdlformatcomment(sprintf('For FCSD of %d, optimizing to CSD due to lower cost',ival))];;
            [tempbody,hdlsignals]=hdlmultiplycsd(in,coeff,coeffptr,out,rounding,saturation);
            hdlbody=[hdlbody,tempbody];
        else

            hdlbody=[hdlbody,hdlformatcomment(...
            sprintf('For FCSD of %d, using factorization: %s\n',...
            ival,sprintf('%d ',ivalfactors)))];

            for n=1:factorlength
                ppcoeffsize=hdl.ceillog2(ivalfactors(n));
                ppsize=min(lastsize+ppcoeffsize,finalsize);
                ppbp=ppcoeffsize+lastbp;
                [pphdltype,ppsltype]=hdlgettypesfromsizes(ppsize,ppbp,resultsigned);
                [uname,ppidx]=hdlnewsignal('factoredcsd_temp','block',-1,0,0,pphdltype,ppsltype);
                hdlsignals=[hdlsignals,makehdlsignaldecl(ppidx)];

                [ppcoeffhdltype,ppcoeffsltype]=hdlgettypesfromsizes(ppcoeffsize,ppcoeffsize,0);
                [uname,coeffptr]=hdlnewsignal('factoredcsd_coefftemp','block',-1,0,0,...
                ppcoeffhdltype,ppcoeffsltype);

                [tempbody,tempsignals]=hdlmultiplycsd(lastsignal,ivalfactors(n)/2^ppcoeffsize,coeffptr,ppidx,...
                'floor',0);

                if strcmpi(tempbody(end-4:end),'\n\n')
                    tempbody=tempbody(1:end-2);
                end
                hdlbody=[hdlbody,tempbody];
                hdlsignals=[hdlsignals,tempsignals];

                lastsize=ppsize;
                lastbp=ppbp;

                if mustpipeline
                    [uname,regppidx]=hdlnewsignal('factoredcsdreg_temp','block',-1,0,0,pphdltype,ppsltype);
                    hdlsignals=[hdlsignals,makehdlsignaldecl(regppidx)];

                    [tempbody,tempsignals]=hdlunitdelay(ppidx,regppidx,'factoredcsdreg',[]);

                    hdlbody=[hdlbody,tempbody];
                    hdlsignals=[hdlsignals,tempsignals];
                    lastsignal=regppidx;
                else
                    lastsignal=ppidx;
                end
            end

            ppbp=(coeffbp+inbp-lastbp)-finalpowerof2;
            [pphdltype,ppsltype]=hdlgettypesfromsizes(finalsize,inbp+coeffbp,resultsigned);
            [uname,ppidx]=hdlnewsignal('factoredcsd_temp','block',-1,0,0,pphdltype,ppsltype);
            hdlsignals=[hdlsignals,makehdlsignaldecl(ppidx)];

            [tempbody,tempsignals]=hdlmultiplypowerof2(lastsignal,2^-ppbp,ppidx,'floor',0);
            hdlbody=[hdlbody,tempbody];
            hdlsignals=[hdlsignals,tempsignals];
            lastsignal=ppidx;

            if mustpipeline
                [uname,finalstage]=hdlnewsignal('factoredcsd_temp','block',-1,0,0,outvtype,outsltype);
                hdlsignals=[hdlsignals,makehdlsignaldecl(finalstage)];
            else
                finalstage=out;
            end

            if ineg
                [tempbody,tempsignals]=hdlunaryminus(lastsignal,finalstage,rounding,saturation);
            else
                tempbody=hdldatatypeassignment(lastsignal,finalstage,rounding,saturation);
            end
            hdlbody=[hdlbody,tempbody];
            hdlsignals=[hdlsignals,tempsignals];

            if mustpipeline

                [tempbody,tempsignals]=hdlunitdelay(finalstage,out,'factoredcsdreg',[]);
                hdlbody=[hdlbody,tempbody];
                hdlsignals=[hdlsignals,tempsignals];
            end

        end
    end



