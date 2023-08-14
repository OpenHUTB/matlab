function[hdlcode,hdlsignals,outRef]=hdlOutRefComp(this,instance,addr)

    snk=this.OutportSnk(instance);

    [outportRe,outportIm]=this.getHDLSignals('out',instance);
    [expectedRe,expectedIm]=this.getHDLSignals('expected',instance);
    isVerilog=hdlgetparameter('isverilog');

    if~this.isTextIOSupported
        isComplex=this.isPortComplex(snk);

        if isVerilog
            openStr='[';
            closeStr=']';
        else
            openStr='(TO_INTEGER(';
            closeStr='))';
        end

        if~snk.dataIsConstant
            for ii=1:length(expectedRe)
                expectedRe{ii}=[expectedRe{ii},openStr,hdlsignalname(addr),closeStr];
                if isComplex
                    expectedIm{ii}=[expectedIm{ii},openStr,hdlsignalname(addr),closeStr];
                end
            end
        end

        if~this.isPortOverClked(snk)

            [hdlsignals,outRef]=this.getRefSignals(snk);
            hdlcode=this.getOutRef(outRef,[outportRe,outportIm],[expectedRe,expectedIm]);
        else

            [curClk,curRst]=setClkandRst(this,snk);


            [hdlsignals,outRef,outRefTmp,dataTable]=this.getRefSignals(snk);


            [curEnb,rd_enb,rd_enbSignal]=setRdenb(snk);
            hdlsignals=[hdlsignals,rd_enbSignal];
            clk_hold=this.hdlclkhold(snk.ClockName);

            hdlcode='';
            hdlbody=hdlcodeinit;

            if isVerilog||(hdlgetparameter('ScalarizePorts')~=0)
                len=snk.VectorPortSize;
            else
                len=1;
            end

            if isVerilog
                for i=1:len
                    hdlcode=[hdlcode,'  assign # ',clk_hold,' '...
                    ,hdlsignalname(dataTable(i)),' = ',expectedRe{i},';\n'];%#ok
                    if isComplex
                        hdlcode=[hdlcode,'  assign # ',clk_hold,' '...
                        ,hdlsignalname(dataTable(i)+1),' = ',expectedIm{i},';\n'];%#ok
                    end

                    bypass=hdl.BypassRegister('dataIn',dataTable(i),...
                    'selectIn',rd_enb,...
                    'dataOut',outRefTmp(i));
                    hdlbody=hdlcodeconcat([hdlbody,bypass.emit]);
                end
            else
                for ii=1:len
                    hdlcode=[hdlcode,hdlsignalname(dataTable(ii)),' <= ',expectedRe{ii}...
                    ,' AFTER ',clk_hold,';\n'];%#ok<AGROW>
                    if isComplex
                        hdlcode=[hdlcode,hdlsignalname(dataTable(ii)+1),' <= '...
                        ,expectedIm{ii},' AFTER ',clk_hold,';\n'];%#ok<AGROW>
                    end
                    bypass=hdl.BypassRegister('dataIn',dataTable(ii),...
                    'selectIn',rd_enb,...
                    'dataOut',outRefTmp(ii));
                    hdlbody=hdlcodeconcat([hdlbody,bypass.emit]);
                end
            end

            hdlbody=hdlbodyCleanup(hdlbody,dataTable,outRefTmp);
            resetClkRstEnb(curRst,curClk,curEnb);

            hdlcode=[hdlcode,'\n',hdlbody.arch_body_blocks];

            for i=1:length(dataTable)
                hdlcode=[hdlcode...
                ,hdlfinalassignment(outRefTmp(i),outRef(i),[],[],len)];%#ok
            end

            hdlcode=[hdlcode,'\n'];
            hdlsignals=[hdlsignals,hdlbody.arch_signals];
        end
    else
        outSignals=[outportRe,outportIm];
        expected=[expectedRe,expectedIm];
        [hdlsignals,outRef]=getRefSignals(this,snk);
        hdlcode='';
        if isVerilog

            if~snk.dataIsConstant
                for kk=1:numel(outRef)
                    hdlcode=[hdlcode,'  assign ',hdlsignalname(outRef(kk)),' = '...
                    ,['fpVal_',char(outSignals{kk})],';\n'];%#ok<AGROW>
                end
            else
                for kk=1:numel(outRef)
                    hdlcode=[hdlcode,'  assign ',hdlsignalname(outRef(kk)),' = '...
                    ,expected{kk},';\n'];%#ok<AGROW>
                end
            end
        else

            if snk.dataIsConstant
                for kk=1:numel(outRef)
                    hdlcode=[hdlcode,hdlsignalname(outRef(kk)),' <= '...
                    ,expected{kk},';\n'];%#ok<AGROW>
                end
            end
        end
    end
end





function[curClk,curRst]=setClkandRst(this,snk)
    curClk=hdlgetcurrentclock;
    curRst=hdlgetcurrentreset;
    hdladdresetsignal(hdlsignalfindname(this.ResetName));
    hdlsetcurrentreset(hdlsignalfindname(this.ResetName));
    if~isempty(snk.ClockName)
        sig=hdlsignalfindname(snk.ClockName);
        hdladdclocksignal(sig);
        hdlsetcurrentclock(sig);
    else
        sig=hdlsignalfindname(this.ClockName);
        hdladdclocksignal(sig);
        hdlsetcurrentclock(sig);
    end
end



function[curEnb,rd_enb,signal]=setRdenb(snk)
    signal='';
    if isempty(snk.dataRdEnb)
        if isa(snk.ClockEnable,'struct')
            rd_enb=snk.ClockEnable.Name;
        else
            rd_enb=snk.ClockEnable;
        end
    else
        if isa(snk.dataRdEnb,'struct')
            rd_enb=snk.dataRdEnb.Name;
        else
            rd_enb=snk.dataRdEnb;
        end
    end
    if hdlgetparameter('isverilog')
        vtype='wire';
    else
        vtype='std_logic';
    end
    if isa(rd_enb,'hdlcoder.port')
        rd_enb=hdlsignalfindname(rd_enb.Name);
    elseif hdlsignalfindname(rd_enb)==0
        [~,rd_enb]=hdlnewsignal(rd_enb,'block',-1,0,0,vtype,'boolean');
        signal=makehdlsignaldecl(rd_enb);
    elseif(isempty(hdlsignalfindname(rd_enb)))
        [~,rd_enb]=hdlnewsignal(rd_enb,'block',-1,0,0,vtype,'boolean');
        signal=makehdlsignaldecl(rd_enb);
    else

        rd_enb=hdlsignalfindname(rd_enb);
    end
    curEnb=hdlgetcurrentclockenable;
    hdladdclockenablesignal(rd_enb);
    hdlsetcurrentclockenable(rd_enb);
end



function resetClkRstEnb(curRst,curClk,curEnb)
    if hdlisresetsignal(curRst)
        hdlsetcurrentreset(curRst);
    end
    if hdlisclocksignal(curClk)
        hdlsetcurrentclock(curClk);
    end
    if hdlisclockenablesignal(curEnb)
        hdlsetcurrentclockenable(curEnb);
    end
end



function hdlcode=hdlbodyCleanup(hdlcode,in,out)
    inType=hdlsignalvtype(in);
    outType=hdlsignalvtype(out);

    if strcmpi(inType,outType)
        hdlcode.arch_body_blocks=regexprep(hdlcode.arch_body_blocks,'unsigned','');
        hdlcode.arch_body_blocks=regexprep(hdlcode.arch_body_blocks,'signed','');
    end
end


