function[hdlbody,hdlsignals]=hdlmultiplycsd(in,coeff,coeffptr,out,rounding,saturation)








    inname=hdlsignalname(in);
    invtype=hdlsignalvtype(in);
    insltype=hdlsignalsltype(in);
    [insize,inbp,insigned]=hdlwordsize(insltype);

    coeffsltype=hdlsignalsltype(coeffptr);
    [coeffsize,coeffbp,coeffsigned]=hdlwordsize(coeffsltype);

    outname=hdlsignalname(out);
    outvtype=hdlsignalvtype(out);
    outsltype=hdlsignalsltype(out);
    [outsize,outbp,outsigned]=hdlwordsize(outsltype);

    [assign_prefix,assign_op]=hdlassignforoutput(out);

    if insize==0
        error(message('HDLShared:directemit:realinput','hdlmultiplycsd',inname));
    elseif insize==1
        error(message('HDLShared:directemit:booleaninputcsd',inname));
    elseif coeff==0
        error(message('HDLShared:directemit:zerocoeff',inname));
    end

    hdlbody='';
    hdlsignals='';

    if insigned==0&&coeffsigned==0
        resultsigned=0;
    else
        resultsigned=1;
    end

    if outsigned==1
        vlogCastBegin='$signed(';
        vlogCastEnd=')';
    else
        vlogCastBegin='';
        vlogCastEnd='';
    end

    if coeff==1
        hdlbody=hdldatatypeassignment(in,out,rounding,saturation);
    else



        [newname,newsize]=hdlsignaltypeconvert(inname,insize,insigned,invtype,resultsigned);

        ival=floor(coeff*2^coeffbp+0.5);
        if ival<0
            ineg=1;
        else
            ineg=0;
        end
        ibits=[0,dec2bin(abs(ival),coeffsize)~='0',0,0];


        csdbits=[];
        startbit=0;
        run=0;
        for n=2:coeffsize+2
            if ibits(n-1)==0&&ibits(n)==1&&ibits(n+1)==0
                csdbits=[csdbits,(coeffsize+1-n),(coeffsize+1-n)];
            elseif ibits(n-1)==0&&ibits(n)==1&&run==0
                run=1;
                startbit=(coeffsize+2-n);
            elseif ibits(n-1)==1&&ibits(n)==0&&run==1
                run=0;
                csdbits=[csdbits,startbit,(coeffsize+2-n)];
            end
        end

        maxshift=max(csdbits(1:2:end));
        prodsize=maxshift+newsize+1;
        prodbp=inbp+coeffbp;

        [tempvtype,tempsltype]=hdlgettypesfromsizes(prodsize,prodbp,resultsigned);
        [tempprod,tempprod_ptr]=hdlnewsignal('mulcsd_temp','block',-1,0,0,tempvtype,tempsltype);
        hdlsignals=[hdlsignals,makehdlsignaldecl(tempprod_ptr)];


        gConnOld=hdlconnectivity.genConnectivity(0);
        if gConnOld,
            hCD=hdlconnectivity.getConnectivityDirector;
            hCD.addDriverReceiverPair(in,tempprod_ptr,'unroll',false,'realonly',true);
        end

        if ineg
            hdlbody=[hdlbody,'  ',assign_prefix,tempprod,' ',assign_op,' - (\n'];
        else
            hdlbody=[hdlbody,'  ',assign_prefix,tempprod,' ',assign_op,' \n'];
        end


        for n=1:2:length(csdbits)
            if csdbits(n)==csdbits(n+1)
                if hdlgetparameter('isvhdl')
                    hdlbody=[hdlbody,'        ','resize(',newname];
                    if csdbits(n)~=0
                        hdlbody=[hdlbody,' & ',vhdlnzeros(csdbits(n))];
                    end
                    hdlbody=[hdlbody,', ',num2str(prodsize),') +\n'];
                elseif hdlgetparameter('isverilog')
                    if csdbits(n)~=0
                        hdlbody=[hdlbody,'        ',vlogCastBegin,'{',newname,...
                        ', ',hdlconstantvalue(0,csdbits(n),0,0),'}',vlogCastEnd];
                    else
                        hdlbody=[hdlbody,'        ',newname];
                    end
                    hdlbody=[hdlbody,' +\n'];
                end
            else
                if hdlgetparameter('isvhdl')
                    hdlbody=[hdlbody,'        ','resize(',newname,' & ',vhdlnzeros(csdbits(n)),...
                    ', ',num2str(prodsize),') -\n'];
                    hdlbody=[hdlbody,'        ','resize(',newname];
                    if csdbits(n+1)~=0
                        hdlbody=[hdlbody,' & ',vhdlnzeros(csdbits(n+1))];
                    end
                    hdlbody=[hdlbody,', ',num2str(prodsize),') +\n'];
                elseif hdlgetparameter('isverilog')
                    hdlbody=[hdlbody,'        ',vlogCastBegin,'{',newname,', ',...
                    hdlconstantvalue(0,csdbits(n),0,0),'}',vlogCastEnd,...
                    ' -\n'];
                    if csdbits(n+1)~=0
                        hdlbody=[hdlbody,'        ',vlogCastBegin,'{',newname,', ',...
                        hdlconstantvalue(0,csdbits(n+1),0,0),'}',vlogCastEnd];
                    else
                        hdlbody=[hdlbody,'        ',newname];
                    end
                    hdlbody=[hdlbody,' +\n'];
                end
            end
        end

        hdlbody=hdlbody(1:end-4);
        if ineg
            hdlbody=[hdlbody,');\n'];
        else
            hdlbody=[hdlbody,';\n'];
        end

        if saturation==0||strcmpi(rounding,'floor')
            final_result=hdltypeconvert(tempprod,prodsize,prodbp,resultsigned,tempvtype,...
            outsize,outbp,outsigned,outvtype,...
            rounding,saturation);



            if~isempty(regexp(final_result,regexptranslate('escape',tempprod),'once'))
                if gConnOld,
                    hCD.addDriverReceiverPair(tempprod_ptr,out,'realonly',false,'unroll',false);
                end
            end


        else
            bpdiff=prodbp-outbp;
            if bpdiff>0
                roundsize=prodsize-bpdiff+1;
            else
                roundsize=outsize+1;
            end

            [temp2vtype,temp2sltype]=hdlgettypesfromsizes(roundsize,outbp,resultsigned);
            [temp2prod,temp2prod_ptr]=hdlnewsignal('mulcsd_temp','block',-1,0,0,temp2vtype,temp2sltype);
            hdlsignals=[hdlsignals,makehdlsignaldecl(temp2prod_ptr)];

            roundedresult=hdltypeconvert(tempprod,prodsize,prodbp,resultsigned,tempvtype,...
            roundsize,outbp,outsigned,temp2vtype,...
            rounding,0);
            convertedresult=hdltypeconvert(temp2prod,roundsize,outbp,resultsigned,temp2vtype,...
            outsize,outbp,outsigned,outvtype,...
            'floor',0);

            hdlbody=[hdlbody,'  ',assign_prefix,temp2prod,' ',assign_op,' ',roundedresult,';\n'];




            if~isempty(regexp(roundedresult,regexptranslate('escape',tempprod),'once'))
                if gConnOld,
                    hCD.addDriverReceiverPair(tempprod_ptr,temp2prod_ptr,'realonly',false,'unroll',false);
                end
            end

            final_result=hdlsaturate(temp2prod,roundsize,outbp,resultsigned,temp2vtype,...
            outsize,outbp,outsigned,outvtype,...
            rounding,saturation,convertedresult);



            if~isempty(regexp(final_result,regexptranslate('escape',temp2prod),'once'))
                if gConnOld,
                    hCD.addDriverReceiverPair(temp2prod_ptr,out,'realonly',false,'unroll',false);
                end
            end

        end

        if~strcmpi(outname,final_result)
            hdlbody=[hdlbody,'  ',assign_prefix,outname,' ',assign_op,' ',final_result,';\n'];
        end


        hdlbody=[hdlbody,'\n'];




        hdlconnectivity.genConnectivity(gConnOld);

    end



