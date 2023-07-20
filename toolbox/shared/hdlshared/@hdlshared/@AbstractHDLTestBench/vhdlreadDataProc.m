function[hdlbody,hdlsignal]=vhdlreadDataProc(this,rdenb,tbenb_dly,...
    txdataCnt,instance,clkrate)



    hdlbody=[];
    hdlsignal=[];
    holdData=[];

    src=this.InportSrc(instance);
    vectorPortSize=src.VectorPortSize;
    sltype=src.PortSLType;
    isDataConst=src.dataIsConstant;
    performIO=this.isTextIOSupported;
    processName=['stimuli_',src.loggingPortName];
    force_data=src.data;
    dataSignals=this.getHDLSignals('force_map',instance);

    [iosize,~,~]=hdlgetsizesfromtype(sltype);

    initialValue=getInitialValue(this,sltype);
    initialValue=vectorizeValue(vectorPortSize,initialValue);

    inSignals=this.getHDLSignals('in',instance);
    ResetName=getResetNameForPort(this,instance,'in');

    holdDataBetweenSamples=this.holdInputDataBetweenSamples;
    initializeInput=this.initializetestbenchinputs;


    clkHold=this.hdlclkhold(this.ClockName);

    rdenbName=hdlsignalname(rdenb);
    sensitivityList=sprintf('%s, %s',hdlsignalname(txdataCnt),rdenbName);
    if initializeInput
        sensitivityList=sprintf('%s, %s',sensitivityList,hdlsignalname(tbenb_dly));
    end

    betweenSampleValue=getUnitializedValue(sltype);
    betweenSampleValue=vectorizeValue(vectorPortSize,betweenSampleValue);

    if performIO
        fpMap=vhdlgetFpMap(this,src);
    else
        fpMap=[];
    end




    if clkrate>1&&holdDataBetweenSamples&&~performIO
        [hdlbody,hdlsignal,holdData]=provideHoldDataBody1(hdlbody,...
        src.ClockName,ResetName,int2str(this.ForceResetValue),initialValue,...
        inSignals,force_data,dataSignals,txdataCnt,processName,isDataConst);
    end

    hdlbody=TxtProcessInstantiation(this,hdlbody,sensitivityList,processName,...
    performIO,src.PortVType,fpMap,isDataConst,vectorPortSize,iosize);


    checkCondition=[rdenbName,' = ','''1'''];
    hdlbody=setInputToInitialVal(hdlbody,initializeInput,initialValue,inSignals,...
    tbenb_dly,clkHold,checkCondition);


    hdlbody=transmitData(this,hdlbody,isDataConst,inSignals,iosize,...
    txdataCnt,dataSignals,force_data,clkHold,performIO,fpMap,vectorPortSize);


    hdlbody=provideHoldDataBody2(hdlbody,holdDataBetweenSamples,inSignals,...
    betweenSampleValue,holdData,clkrate,clkHold,performIO);

    hdlbody=[hdlbody,...
    '    END IF;\n',...
    '  END PROCESS ',processName,';\n\n'];
end




function value=getUnitializedValue(sltype)
    if strcmpi(sltype,'double')
        value=hdlconstantvalue(1.0E-9,0,0,1);
    elseif hdlgetsizesfromtype(sltype)==1
        value='''X''';
    else
        value='( OTHERS => ''X'')';
    end
end



function initialValue=getInitialValue(this,sltype)

    if this.initializetestbenchinputs
        if strcmpi(sltype,'double')
            initialValue=hdlconstantvalue(0.0E-0,0,0,1);
        elseif hdlgetsizesfromtype(sltype)==1
            initialValue='''0''';
        else
            initialValue='(OTHERS => ''0'')';
        end
    else
        initialValue=getUnitializedValue(sltype);
    end
end



function value=vectorizeValue(vectorSize,value)
    if(hdlgetparameter('ScalarizePorts')==0)&&(vectorSize>1)
        value=['( OTHERS => ',value,')'];
    end
    value=[' <= ',value];
end


function[hdlbody,hdlsignal,holdData]=provideHoldDataBody1(hdlbody,...
    ClockName,ResetName,resetValue,initialValue,inSignals,...
    force_data,dataSignals,txdataCnt,processName,isDataConst)


    hdlbody=[hdlbody,...
    '  ',processName,'_reg: PROCESS(',ClockName,', ',ResetName,')\n'];
    hdlbody=[hdlbody,...
    '  BEGIN\n',...
    '   IF ',ResetName,' = ''',resetValue,''' THEN\n'];%#ok<*I18N_Concatenated_Msg>

    hdlsignal=cell(1,length(inSignals));
    holdData=zeros(1,length(inSignals));
    for i=1:length(inSignals)
        sltype=hdlsignalsltype(hdlsignalfindname(inSignals{i}));
        vtype=hdlsignalvtype(hdlsignalfindname(inSignals{i}));
        [~,holdData(i)]=hdlnewsignal(['holdData_',inSignals{i}],'block',-1,0,0,vtype,sltype);
        hdlsignal{i}=makehdlsignaldecl(holdData(i));
        hdlbody=[hdlbody,...
        '      ',hdlsignalname(holdData(i)),initialValue,';\n'];%#ok<*AGROW>
    end

    if hdlgetparameter('clockedge')==0
        hdlbody=[hdlbody,...
        '   ELSIF ',ClockName,'''event AND ',ClockName,' = ''1'' THEN\n'];
    else
        hdlbody=[hdlbody,...
        '   ELSIF ',ClockName,'''event AND ',ClockName,' = ''0'' THEN\n'];
    end

    for i=1:length(inSignals)
        if isempty(force_data)
            hdlbody=[hdlbody,...
            hdlgetparameter('comment_char'),' No Input data for %s ',inSignals{i}];
        elseif isDataConst
            hdlbody=[hdlbody,...
            '        ',hdlsignalname(holdData(i)),' <= ',dataSignals{i},';\n'];
        else
            hdlbody=[hdlbody,...
            '        ',hdlsignalname(holdData(i)),' <= ',dataSignals{i},'(TO_INTEGER(',hdlsignalname(txdataCnt),'));\n'];
        end
    end

    hdlbody=[hdlbody,...
    '   END IF;\n'];

    hdlbody=[hdlbody,...
    '  END PROCESS ',processName,'_reg;\n\n'];

end

function hdlbody=TxtProcessInstantiation(this,hdlbody,sensitivityList,...
    processName,performIO,vtype,fpMap,isDataConst,vectorPortSize,iosize)
    hdlbody=sprintf('%s  %s : PROCESS(%s)\n',hdlbody,processName,sensitivityList);

    if performIO&&~isDataConst
        hdlbody=this.vhdlGetfpVarDeclaration(hdlbody,fpMap,vtype,vectorPortSize,iosize);
    end

    hdlbody=[hdlbody,'  BEGIN\n'];
end


function hdlbody=setInputToInitialVal(hdlbody,initializeInput,initialValue,inSignals,...
    tbenb_dly,clkHold,checkCondition)

    if initializeInput
        hdlbody=[hdlbody,...
        '    IF ',hdlsignalname(tbenb_dly),' = ''0'' THEN\n'];
        for i=1:length(inSignals)
            hdlbody=[hdlbody,...
            '      ',inSignals{i},initialValue,' AFTER ',clkHold,';\n'];
        end
        hdlbody=[hdlbody,...
        '    ELSIF ',checkCondition,' THEN\n'];
    else
        hdlbody=[hdlbody,...
        '    IF ',checkCondition,' THEN\n'];
    end
end


function hdlbody=transmitData(this,hdlbody,isDataConst,inSignals,iosize,...
    txdataCnt,dataSignals,force_data,clkHold,performIO,fpMap,vectorPortSize)

    if isempty(force_data)
        hdlbody=[hdlbody,...
        hdlgetparameter('comment_char'),' No Input data for %s ',inSignals{1}];
    elseif isDataConst
        for ii=1:length(inSignals)
            hdlbody=[hdlbody,...
            '      ',inSignals{ii},' <= ',dataSignals{ii},' AFTER ',clkHold,';\n'];
        end
    elseif~performIO
        for ii=1:length(inSignals)
            hdlbody=[hdlbody,...
            '      ',inSignals{ii},' <= ',dataSignals{ii},'(TO_INTEGER(',hdlsignalname(txdataCnt),')) AFTER ',clkHold,';\n'];
        end
    else
        hdlbody=this.vhdlProvideReadFunc(hdlbody,fpMap,iosize,clkHold,'Txt',vectorPortSize);

    end
end


function hdlbody=provideHoldDataBody2(hdlbody,holdDataBetweenSamples,inSignals,...
    betweenSampleValue,holdData,clkrate,clkHold,performIO)
    if~holdDataBetweenSamples
        hdlbody=[hdlbody,'    ELSE\n'];
        for i=1:length(inSignals)
            hdlbody=[hdlbody,...
            '      ',inSignals{i},betweenSampleValue,' AFTER ',clkHold,';\n'];
        end
    elseif clkrate>1&&~performIO
        hdlbody=[hdlbody,'    ELSE\n'];
        for i=1:length(inSignals)
            hdlbody=[hdlbody,...
            '      ',inSignals{i},' <= ',hdlsignalname(holdData(i)),' AFTER ',clkHold,';\n'];
        end
    end
end
