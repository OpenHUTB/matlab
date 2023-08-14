function hdlbody=verilogchecker(this,rdenb,checker_enb,addr,...
    instance,errCnt,testFailure)



    rd_enb=hdlsignalname(rdenb);
    chk_enb=hdlsignalname(checker_enb);
    tstFailed=hdlsignalname(testFailure);
    snk=this.OutportSnk(instance);
    performIO=isTextIOSupported(this);

    outSignals=this.getHDLSignals('out',instance);
    severitylevel='';

    if(this.ForceResetValue==0)
        resetedge='negedge';
    else
        resetedge='posedge';
    end

    [checkCondition,checkConditionSkip]=getCheckCond(chk_enb,rd_enb,performIO);
    vectorPortSize=snk.VectorPortSize;
    ClockName=this.OutportSnk(instance).ClockName;
    ResetName=getResetNameForPort(this,instance,'out');

    if(performIO&&snk.dataIsConstant)||~performIO
        [expectedRe,expectedIm]=this.getHDLSignals('expected',instance);
    else
        [expectedRe,expectedIm]=this.getHDLSignals('out',instance);
    end

    [outRe,outIm]=this.getHDLSignals('out',snk);

    if performIO
        if(snk.dataIsConstant==0)
            [~,fpScanMap]=this.getFpMap(outSignals,vectorPortSize,snk);
        else
            fpScanMap=[];
        end
    else
        fpScanMap=[];
    end


    hdlbody=provideReset(ClockName,resetedge,snk,ResetName,...
    this,vectorPortSize,errCnt,tstFailed,performIO,fpScanMap);
    hdlbody=provideCheckCondition(hdlbody,snk,chk_enb,checkCondition,checkConditionSkip,...
    performIO,outSignals,vectorPortSize,this);

    if performIO
        if(snk.dataIsConstant==0)
            hdlbody=scanFromFile(hdlbody,fpScanMap);
        end
    end

    for ii=1:vectorPortSize
        eCnt=hdlsignalname(errCnt(ii));

        [currentExpectedRe,currentExpectedIm]=getExpectedVal(expectedRe,expectedIm,...
        addr,ii,snk,performIO,this);

        hdlbody=provideAssertSection(this,hdlbody,snk,outRe,outIm,ii,...
        currentExpectedRe,currentExpectedIm,tstFailed,eCnt,severitylevel);
    end

    hdlbody=sprintf('%s      end\n    end\n  end // checker_%s\n\n',hdlbody,snk.loggingPortName);
end




function hdlbody=provideReset(ClockName,resetedge,snk,...
    ResetName,this,vectorPortSize,errCnt,tstFailed,performIO,fpScanMap)

    if hdlgetparameter('clockedge')==0
        clk_str=['  always @ (posedge ',ClockName,' or ',resetedge];
    else
        clk_str=['  always @ (negedge ',ClockName,' or ',resetedge];
    end

    hdlbody=['\n\n',...
    clk_str,...
    ' ',ResetName,') // checker_',...
    snk.loggingPortName,'\n',...
    '  begin\n',...
    sprintf('    if (%s == %d) begin\n',ResetName,this.ForceResetValue),...
    '      ',tstFailed,' <= 0;\n'];

    for ii=1:vectorPortSize
        eCnt=hdlsignalname(errCnt(ii));
        hdlbody=[hdlbody,'      ',eCnt,' <= 0;\n'];%#ok<*AGROW>
    end
    if performIO
        if(snk.dataIsConstant==0)

            keySet=fpScanMap.keys;
            for kk=1:numel(keySet)
                hdlbody=[hdlbody,...
                '      ',...
                ['rewindFpStatus_',char(keySet{kk})]...
                ,' <= ','$rewind',...
                ' (',['fp_',char(keySet{kk})],')',';',...
                '\n'];
            end
        end
    end
end

function hdlbody=provideCheckCondition(hdlbody,snk,chk_enb,...
    checkCondition,checkConditionSkip,...
    performIO,outSignals,vectorPortSize,this)

    if((snk.dataIsConstant==0)&&~isempty(chk_enb)&&performIO)



        hdlbody=[hdlbody,...
        '    end \n',...
        '    else begin \n',...
        '      if (',checkConditionSkip,') begin \n'];
        [~,fpScanMap]=this.getFpMap(outSignals,vectorPortSize,snk);
        hdlbody=scanFromFile(hdlbody,fpScanMap);

        hdlbody=[hdlbody,'    end \n'];
        hdlbody=[hdlbody,...
        '      if (',checkCondition,') begin \n'];
    else
        hdlbody=[hdlbody,...
        '    end \n',...
        '    else begin \n',...
        '      if (',checkCondition,') begin \n'];
    end
end

function[currentExpectedRe,currentExpectedIm]=getExpectedVal(expectedRe,expectedIm,...
    addr,index,snk,performIO,this)
    if(snk.dataIsConstant==0)
        if performIO
            currentExpectedRe=['fpVal_',expectedRe{index}];
            if this.isPortComplex(snk)
                currentExpectedIm=['fpVal_',expectedIm{index}];
            else
                currentExpectedIm=[];
            end
        else
            currentExpectedRe=[expectedRe{index},'[',hdlsignalname(addr),']'];
            if this.isPortComplex(snk)
                currentExpectedIm=[expectedIm{index},'[',hdlsignalname(addr),']'];
            else
                currentExpectedIm=[];
            end
        end
    else
        currentExpectedRe=expectedRe{index};
        if this.isPortComplex(snk)
            currentExpectedIm=expectedIm{index};
        else
            currentExpectedIm=[];
        end
    end
end

function hdlbody=provideAssertSection(this,hdlbody,snk,outRe,outIm,index,...
    currentExpectedRe,currentExpectedIm,tstFailed,eCnt,severitylevel)
    if this.isPortComplex(snk)
        signame_re=outRe{index};
        signame_im=outIm{index};

        [testfailure,reDisplay]=this.getTestFailureText({signame_re,signame_im},...
        {currentExpectedRe,currentExpectedIm},true);
        assert_section=['        if (',testfailure,') begin\n',...
        '           ',eCnt,' <= ',eCnt,' + 1;\n',...
        '           ',tstFailed,' <= 1;\n',...
        '    ',reDisplay,...
        severitylevel,...
        '           if (',eCnt,' >= MAX_ERROR_COUNT) \n',...
'             $display("Warning: Number of errors for '...
        ,signame_re,'/',signame_im...
        ,' have exceeded the maximum error limit");\n',...
        '        end\n\n'];
    else
        signame=outRe{index};
        [testfailure,display]=...
        this.getTestFailureText(signame,currentExpectedRe);
        assert_section=['        if (',testfailure,') begin\n',...
        '           ',eCnt,' <= ',eCnt,' + 1;\n',...
        '           ',tstFailed,' <= 1;\n',...
        '    ',display,...
        severitylevel,...
        '           if (',eCnt,' >= MAX_ERROR_COUNT) \n',...
'             $display("Warning: Number of errors for '...
        ,signame,' have exceeded the maximum error limit");\n',...
        '        end\n\n'];
    end
    hdlbody=[hdlbody,assert_section];
end

function hdlbody=scanFromFile(hdlbody,fpScanMap)
    ScanValueSet=fpScanMap.values;
    ScanKeySet=fpScanMap.keys;


    for jj=1:numel(ScanValueSet)
        flatVal=cellstr(ScanValueSet{jj});
        fpKey=ScanKeySet{jj};
        for kk=1:numel(flatVal)
            hdlbody=[hdlbody,...
            '        rStatus_',char(flatVal{kk}),' <= $fscanf(fp_',...
            char(fpKey),',"%%h",fpVal_',char(flatVal{kk}),');\n'];
        end
    end
end

function[checkCondition,checkConditionSkip]=getCheckCond(chk_enb,rd_enb,performIO)
    if isempty(chk_enb)
        checkCondition=[rd_enb,' == 1 '];
    else
        checkCondition=[rd_enb,' == 1 && ',chk_enb,' == 1 '];
    end

    if performIO

        checkConditionSkip=[rd_enb,' == 1 && ',chk_enb,' == 0 '];
    else

        checkConditionSkip=[];
    end
end
