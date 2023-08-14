function hdlbody=vhdlchecker(this,rdenb,checker_enb,addr,instance,...
    errCnt,testFailure)



    hdlbody=[];

    rd_enb=hdlsignalname(rdenb);
    chk_enb=hdlsignalname(checker_enb);
    tstFailed=hdlsignalname(testFailure);
    snk=this.OutportSnk(instance);
    performIO=isTextIOSupported(this);
    resetVal=this.ForceResetValue;
    vectorPortSize=snk.VectorPortSize;
    isDataConst=snk.dataIsConstant;
    vtype=snk.PortVType;
    sltype=snk.PortSLType;
    [iosize,~,~]=hdlgetsizesfromtype(sltype);
    [outRe,outIm]=this.getHDLSignals('out',instance);
    outSignals=this.getHDLSignals('out',instance);
    severitylevel='ERROR';

    if performIO
        fpTransmitMap=this.getFpMap(outSignals,vectorPortSize,snk);
    else
        fpTransmitMap=[];
    end

    if(performIO&&snk.dataIsConstant)||~performIO
        [expectedRe,expectedIm]=this.getHDLSignals('expected',instance);
    else
        [expectedRe,expectedIm]=this.getHDLSignals('out',instance);
    end



    if(hdlgetparameter('ScalarizePorts')~=0)
        numCheckers=snk.VectorPortSize;
    else
        numCheckers=1;
    end

    [checkCondition,checkConditionSkip]=getCheckCond(chk_enb,rd_enb,performIO);
    ClockName=this.OutportSnk(instance).ClockName;
    ResetName=getResetNameForPort(this,instance,'out');

    hdlbody=CheckerProcessInstantiation(this,hdlbody,instance,ClockName,ResetName,...
    performIO,isDataConst,fpTransmitMap,vtype,vectorPortSize,iosize);
    hdlbody=provideReset(hdlbody,resetVal,ResetName,errCnt,numCheckers);

    hdlbody=provideCheckCondition(hdlbody,snk,chk_enb,...
    checkCondition,checkConditionSkip,...
    performIO,iosize,outSignals,vectorPortSize,this,tstFailed,ClockName);

    if performIO
        if(snk.dataIsConstant==0)
            hdlbody=this.vhdlProvideReadFunc(hdlbody,fpTransmitMap,iosize,[],'Rx',vectorPortSize);
        end
    end

    for ii=1:numCheckers
        eCnt=hdlsignalname(errCnt(ii));
        [currentExpectedRe,currentExpectedIm]=getExpectedVal(expectedRe,expectedIm,...
        addr,ii,snk,performIO,this);

        hdlbody=provideAssertSection(this,hdlbody,snk,outRe,outIm,...
        currentExpectedRe,currentExpectedIm,tstFailed,eCnt,severitylevel,ii);
    end

    hdlbody=sprintf('%s      END IF;\n    END IF;\n  END PROCESS checker_%d;\n\n',hdlbody,instance);
end



function[checkCondition,checkConditionSkip]=getCheckCond(chk_enb,rd_enb,performIO)
    quoteOne=[char(39),'1',char(39)];
    quoteZero=[char(39),'0',char(39)];
    if isempty(chk_enb)
        checkCondition=[rd_enb,' = ',quoteOne];
    else
        checkCondition=[rd_enb,' = ',quoteOne,' AND ',chk_enb,' = ',quoteOne];
    end

    if performIO

        checkConditionSkip=[rd_enb,' = ',quoteOne,' AND ',chk_enb,' = ',quoteZero];
    else

        checkConditionSkip=[];
    end
end

function[currentExpectedRe,currentExpectedIm]=getExpectedVal(expectedRe,expectedIm,...
    addr,index,snk,performIO,this)
    currentExpectedIm=[];
    if(snk.dataIsConstant==0)
        if performIO
            currentExpectedRe=[expectedRe{index},'_expected'];
            if this.isPortComplex(snk)
                currentExpectedIm=[expectedIm{index},'_expected'];
            else
                currentExpectedIm=[];
            end
        else
            currentExpectedRe=[expectedRe{index},'(TO_INTEGER(',hdlsignalname(addr),'))'];
            if this.isPortComplex(snk)
                currentExpectedIm=[expectedIm{index},'(TO_INTEGER(',hdlsignalname(addr),'))'];
            end
        end
    else
        currentExpectedRe=expectedRe{index};
        if this.isPortComplex(snk)
            currentExpectedIm=expectedIm{index};
        end
    end

end

function hdlbody=provideReset(hdlbody,resetVal,ResetName,errCnt,numCheckers)
    hdlbody=sprintf('%s    IF %s = ''%d'' THEN\n',hdlbody,ResetName,resetVal);
    for ii=1:numCheckers
        hdlbody=[hdlbody,'      ',hdlsignalname(errCnt(ii)),' <= 0;\n'];%#ok<AGROW>
    end
end

function hdlbody=CheckerProcessInstantiation(this,hdlbody,instance,ClockName,ResetName,...
    performIO,isDataConst,fpTransmitMap,vtype,vectorPortSize,iosize)
    hdlbody=[hdlbody,sprintf('  checker_%d: PROCESS(%s, %s)\n',instance,ClockName,ResetName)];

    if performIO&&~isDataConst
        hdlbody=this.vhdlGetfpVarDeclaration(hdlbody,fpTransmitMap,vtype,vectorPortSize,iosize);
    end

    hdlbody=[hdlbody,'  BEGIN\n'];
end

function hdlbody=provideCheckCondition(hdlbody,snk,chk_enb,...
    checkCondition,checkConditionSkip,...
    performIO,iosize,outSignals,vectorPortSize,this,tstFailed,ClockName)

    if hdlgetparameter('clockedge')==0
        hdlbody=[hdlbody,...
        '      ',tstFailed,' <= ''0'';\n',...
        '    ELSIF ',ClockName,'''event and ',ClockName,' =''1'' THEN\n'];

    else
        hdlbody=[hdlbody,...
        '      ',tstFailed,' <= ''0'';\n',...
        '    ELSIF ',ClockName,'''event and ',ClockName,' =''0'' THEN\n'];
    end

    if((snk.dataIsConstant==0)&&~isempty(chk_enb)&&performIO)



        hdlbody=[hdlbody,...
        '      IF (',checkConditionSkip,') THEN\n'];
        [fpTransmitMap,~]=this.getFpMap(outSignals,vectorPortSize,snk);
        hdlbody=this.vhdlProvideReadFunc(hdlbody,fpTransmitMap,iosize,[],'Rx',vectorPortSize);

        hdlbody=[hdlbody,'    END IF; \n'];
        hdlbody=[hdlbody,...
        '      IF ',checkCondition,' THEN\n'];
    else
        hdlbody=[hdlbody,...
        '      IF ',checkCondition,' THEN\n'];
    end
end


function hdlbody=provideAssertSection(this,hdlbody,snk,outRe,outIm,...
    currentExpectedRe,currentExpectedIm,tstFailed,eCnt,severitylevel,index)
    if this.isPortComplex(snk)
        report=['            REPORT "Error in ',outRe{index},'/',outIm{index},...
        ': Expected (real) " \n'];
        expectedVSactual=['            & to_hex(',currentExpectedRe,')\n',...
        '            & " Actual (real) "\n',...
        '            & to_hex(',outRe{index},')\n',...
        '            & " Expected (imaginary) "\n',...
        '            & to_hex(',currentExpectedIm,')\n',...
        '            & " Actual (imaginary) "\n',...
        '            & to_hex(',outIm{index},')\n'];
        testfailure=sprintf('(%s) OR (%s)',...
        this.getTestFailureText(outRe{index},currentExpectedRe),...
        this.getTestFailureText(outIm{index},currentExpectedIm));
    else
        report=['            REPORT "Error in ',outRe{index},': Expected " \n'];
        expectedVSactual=['            & to_hex(',currentExpectedRe,')\n',...
        '            & " Actual "\n',...
        '            & to_hex(',outRe{index},')\n'];
        testfailure=this.getTestFailureText(outRe{index},currentExpectedRe);
    end

    assert_section=[...
    '        IF ',testfailure,' THEN\n',...
    '          ',eCnt,' <= ',eCnt,' + 1;\n',...
    '          ',tstFailed,' <= ''1'';\n',...
    '          ASSERT FALSE \n',...
    report,expectedVSactual,...
    '            SEVERITY ',severitylevel,';\n',...
    '          IF ',eCnt,' >= MAX_ERROR_COUNT THEN\n',...
    '            ASSERT FALSE\n',...
    '              REPORT "Number of errors have exceeded the maximum error"\n',...
    '              SEVERITY Warning;\n',...
    '          END IF;\n',...
    '        END IF;\n'];
    hdlbody=sprintf('%s%s',hdlbody,assert_section);
end
