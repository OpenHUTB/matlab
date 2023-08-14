function[hdlbody,hdlsignals]=hdlrdenb(this,rdenb,clkenb,snkDone,srcDone)





    bdt=hdlgetparameter('base_data_type');
    if length(this.OutportSnk)>0
        testCounter=hdlsignalname(snkDone);
    else
        testCounter=hdlsignalname(srcDone);
    end

    hdlbody='';
    hdlsignals='';

    if(this.clkrate>1)
        if~isempty(this.InportSrc)
            if hdlgetparameter('isvhdl')
                hdlbody=[hdlbody,...
                '  ',hdlsignalname(rdenb),' <= ',hdlsignalname(clkenb),';\n\n'];

            else
                hdlbody=[hdlbody,...
                '      assign ',hdlsignalname(rdenb),' = ',hdlsignalname(clkenb),';\n\n'];
            end
        end
    else
        if hdlgetparameter('isvhdl')
            testCounter=[testCounter,' =  ''0'''];
            hdlbody=['  ',hdlsignalname(rdenb),' <= ',hdlsignalname(clkenb),' WHEN ',testCounter,' ELSE\n',...
            '           ''0'';\n\n'];
        else
            hdlbody=['  always @(',testCounter,', ',hdlsignalname(clkenb),')\n',...
            '  begin\n',...
            '    if (',testCounter,' == 0)\n',...
            '      ',hdlsignalname(rdenb),' <= ',hdlsignalname(clkenb),';\n',...
            '    else\n',...
            '      ',hdlsignalname(rdenb),' <= 0;\n',...
            '  end\n\n'];
        end
    end