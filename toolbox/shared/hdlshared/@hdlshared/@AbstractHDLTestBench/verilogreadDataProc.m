function[hdlbody,hdlsignal]=verilogreadDataProc(this,rdenb,tbenb_dly,txdataCnt,instance,clkrate)



    hdlbody=[];
    hdlsignal=[];
    holdData=[];
    src=this.InportSrc(instance);
    vectorPortSize=src.VectorPortSize;
    portsltype=src.PortSLType;
    isDataConst=src.dataIsConstant;
    performIO=isTextIOSupported(this);

    forceSignals=this.getHDLSignals('force_map',instance);
    ClockName=this.InportSrc(instance).ClockName;
    ResetName=getResetNameForPort(this,instance,'in');

    if vectorPortSize>1||this.isPortComplex(src)
        Sizes=max(hdlsignalsizes(hdlsignalfindname(src.HDLPortName{1}{1})));
    else
        Sizes=max(hdlsignalsizes(hdlsignalfindname(src.HDLPortName{1})));
    end

    processName=['stimuli_',src.loggingPortName];
    signame=src.HDLPortName;
    force_data=src.data;

    holdDataBetweenSamples=this.holdInputDataBetweenSamples;
    initializeInput=this.initializetestbenchinputs;
    inSignals=this.getHDLSignals('in',instance);


    clkHold=this.hdlclkhold(this.ClockName);


    if strcmpi(portsltype,'double')
        vectorset=' <= 1.0E-9';
    elseif strcmp(portsltype,'boolean')||strcmpi(portsltype,'ufix1')
        vectorset=' <= 1''bx';
    else
        vectorset=[' <= ',int2str(Sizes),'''bx'];
    end

    if(this.ForceResetValue==0)
        reset_edge='negedge';
        reset_inv='~';
    else
        reset_edge='posedge';
        reset_inv='';
    end

    rdenbName=hdlsignalname(rdenb);
    sensitivityList=sprintf('%s, %s',rdenbName,hdlsignalname(txdataCnt));
    if initializeInput
        sensitivityList=sprintf('%s, %s',sensitivityList,hdlsignalname(tbenb_dly));
    end

    for ii=1:length(inSignals)
        processName=[processName,'_',inSignals{ii}];
    end



    initialvectorset=setInitialVector(portsltype,initializeInput,Sizes);





    [hdlbody,hdlsignal,rawhdlsignal]=rawForceData(hdlbody,hdlsignal,...
    inSignals,force_data,forceSignals,...
    src,txdataCnt);

    if clkrate>1&&holdDataBetweenSamples&&~performIO
        [hdlbody,hdlsignal,holdData]=provideHoldDataBody1(hdlbody,signame,hdlsignal,...
        ClockName,reset_edge,reset_inv,ResetName,...
        initialvectorset,inSignals,force_data,forceSignals,...
        src,txdataCnt,processName,rawhdlsignal);
    else

    end

    hdlbody=TxtAlwaysInstantiation(hdlbody,sensitivityList,clkrate,...
    ResetName,processName,performIO);


    checkCondition=[rdenbName,' == 1'];
    hdlbody=setInputToInitialVal(hdlbody,initializeInput,initialvectorset,inSignals,...
    tbenb_dly,clkHold,checkCondition);

    if performIO
        [fpTransmitMap,fpScanMap]=this.getFpMap(inSignals,vectorPortSize,src);


        hdlbody=rewindFp(hdlbody,fpScanMap,reset_inv,ResetName,isDataConst);
    else
        fpTransmitMap=[];
        fpScanMap=[];
    end


    hdlbody=transmitData(hdlbody,signame,src,inSignals,...
    forceSignals,txdataCnt,fpTransmitMap,fpScanMap,...
    performIO,force_data,clkHold,rawhdlsignal);

    hdlbody=provideHoldDataBody2(hdlbody,holdDataBetweenSamples,inSignals,...
    vectorset,holdData,clkrate,clkHold,performIO);

    hdlbody=[hdlbody,'    end\n'];

    hdlbody=[hdlbody,...
    '  end ',hdlgetparameter('comment_char'),' ',processName,'\n\n'];
end




function hdlbody=TxtAlwaysInstantiation(hdlbody,sensitivityList,...
    clkrate,ResetName,processName,performIO)
    hdlbody=[hdlbody,'  always @ (',sensitivityList];
    if performIO&&(clkrate>1)
        hdlbody=[hdlbody,',',ResetName];
    end
    hdlbody=[hdlbody,')\n  begin '];

    hdlbody=[hdlbody,hdlgetparameter('comment_char'),' ',processName,'\n'];
end

function hdlbody=rewindFp(hdlbody,fpMap,reset_inv,ResetName,isDataConst)


    if~isDataConst
        hdlbody=[hdlbody,...
        '    if (',reset_inv,ResetName,') begin \n'];
        keySet=fpMap.keys;
        for kk=1:numel(keySet)
            hdlbody=[hdlbody...
            ,'        ',['rewindFpStatus_',char(keySet{kk})]...
            ,' <= ','$rewind',...
            ' (',['fp_',char(keySet{kk})],')',';',...
            '\n'];
        end
        hdlbody=[hdlbody,'    end else\n'];
    end
end

function initialvectorset=setInitialVector(portsltype,initializeInput,Sizes)

    if strcmpi(portsltype,'double')
        if initializeInput
            initialvectorset=[' ',hdlconstantvalue(0.0E-0,0,0,1)];
        else
            initialvectorset=[' ',hdlconstantvalue(1.0E-9,0,0,1)];
        end
    elseif strcmp(portsltype,'boolean')||strcmpi(portsltype,'ufix1')
        if initializeInput
            initialvectorset=' 1''b0';
        else
            initialvectorset=' 1''bx';
        end
    else
        if initializeInput
            initialvectorset=[' ',num2str(Sizes),'''b0'];
        else
            initialvectorset=[' ',num2str(Sizes),'''bx'];
        end
    end
end

function hdlbody=setInputToInitialVal(hdlbody,initializeInput,...
    initialvectorset,inSignals,tbenb_dly,clkHold,checkCondition)

    if initializeInput
        hdlbody=[hdlbody,...
        '    if (',hdlsignalname(tbenb_dly),' == 0) begin\n'];
        for ii=1:length(inSignals)
            hdlbody=[hdlbody,...
            '      ',inSignals{ii},' <= # ',clkHold,' ',initialvectorset,';\n'];
        end

        hdlbody=[hdlbody,...
        '    end\n',...
        '    else if (',checkCondition,') begin\n'];
    else
        hdlbody=[hdlbody,...
        '    if (',checkCondition,') begin\n'];
    end
end

function hdlbody=transmitData(hdlbody,signame,src,inSignals,...
    forceSignals,txdataCnt,fpTransmitMap,fpScanMap,performIO,force_data,clkHold,rawhdlsignal)
    if isempty(force_data)
        hdlbody=[hdlbody,...
        hdlgetparameter('comment_char'),' No Input data for %s ',signame];
    elseif(src.dataIsConstant==1)
        for ii=1:length(inSignals)
            hdlbody=[hdlbody,...
            '      ',inSignals{ii},' <= # ',clkHold,' ',forceSignals{ii},';\n'];
        end
    elseif~performIO
        for ii=1:length(inSignals)
            hdlbody=[hdlbody,...
            '      ',inSignals{ii},' <= # ',clkHold,' ',hdlsignalname(rawhdlsignal(ii)),';\n'];
        end

    else

        hdlbody=scanFromFile(hdlbody,fpScanMap);


        hdlbody=TxtFpValToDut(hdlbody,fpTransmitMap,clkHold);
    end
end

function[hdlbody,hdlsignal,holdData]=provideHoldDataBody1(hdlbody,signame,hdlsignal,...
    ClockName,reset_edge,reset_inv,ResetName,...
    initialvectorset,inSignals,force_data,forceSignals,...
    src,txdataCnt,processName,rawhdlsignal)

    if hdlgetparameter('clockedge')==0
        clk_str=['  always @ (posedge ',ClockName,' or ',reset_edge,' ',ResetName,')\n'];
    else
        clk_str=['  always @ (negedge ',ClockName,' or ',reset_edge,' ',ResetName,')\n'];
    end

    hdlbody=[hdlbody,...
    clk_str,...
    '  begin ',...
    hdlgetparameter('comment_char'),' ',processName,'_reg\n',...
    '    if (',reset_inv,ResetName,') begin \n'];%#ok<*I18N_Concatenated_Msg>

    for ii=1:length(inSignals)
        inSignal=hdlsignalfindname(inSignals{ii});
        portsltype=hdlsignalsltype(inSignal);
        vtype=hdlsignalvtype(inSignal);
        [~,holdData(ii)]=hdlnewsignal(['holdData_',inSignals{ii}],'block',-1,0,0,vtype,portsltype);
        hdlregsignal(holdData(ii));
        hdlsignal=[hdlsignal,makehdlsignaldecl(holdData(ii))];
        hdlbody=[hdlbody,...
        '      ',hdlsignalname(holdData(ii)),' <= ',initialvectorset,';\n'];
    end
    hdlbody=[hdlbody,...
    '    end\n',...
    '    else begin\n'];

    for ii=1:length(inSignals)
        if isempty(force_data)
            hdlbody=[hdlbody,...
            hdlgetparameter('comment_char'),' No Input data for %s ',signame];
        elseif(src.dataIsConstant==1)
            hdlbody=[hdlbody,...
            '      ',hdlsignalname(holdData(ii)),' <= ',forceSignals{ii},';\n'];
        else
            hdlbody=[hdlbody,...
            '      ',hdlsignalname(holdData(ii)),' <= ',hdlsignalname(rawhdlsignal(ii)),';\n'];
        end
    end
    hdlbody=[hdlbody,...
    '    end\n',...
    '  end\n\n'];
end

function hdlbody=provideHoldDataBody2(hdlbody,holdDataBetweenSamples,...
    inSignals,vectorset,holdData,clkrate,clkHold,performIO)
    if~holdDataBetweenSamples
        hdlbody=[hdlbody,...
        '    end\n',...
        '    else begin \n'];
        for ii=1:length(inSignals)
            hdlbody=[hdlbody,...
            '      ',inSignals{ii},vectorset,';\n'];
        end
    elseif clkrate>1&&~performIO
        hdlbody=[hdlbody,...
        '    end\n',...
        '    else begin \n'];
        for ii=1:length(inSignals)
            hdlbody=[hdlbody,...
            '      ',inSignals{ii},' <= # ',clkHold,' ',hdlsignalname(holdData(ii)),';\n'];%#ok<*AGROW>
        end
    end
end

function hdlbody=scanFromFile(hdlbody,fpScanMap)
    ScanValueSet=fpScanMap.values;
    ScanKeySet=fpScanMap.keys;


    for jj=1:numel(ScanValueSet)
        flatVal=cellstr(ScanValueSet{jj});
        fpKey=ScanKeySet{jj};
        for kk=1:numel(flatVal)
            hdlbody=[hdlbody,...
            '        ',['rStatus_',char(flatVal{kk})]...
            ,' <= ','$fscanf',...
            ' (',['fp_',char(fpKey)],',',...
            '"%%h"',',',...
            ['fpVal_',char(flatVal{kk})],')',';',...
            '\n'];
        end
    end
end

function hdlbody=TxtFpValToDut(hdlbody,fpTransmitMap,clkHold)
    TxtValueSet=fpTransmitMap.values;
    TxtKeySet=fpTransmitMap.keys;

    for jj=1:numel(TxtValueSet)
        flatVal=cellstr(TxtValueSet{jj});
        fpKey=TxtKeySet{jj};
        for kk=1:numel(flatVal)
            hdlbody=[hdlbody,...
            '        ',char(flatVal{kk})...
            ,' <= # ',clkHold,...
            ' ',['fpVal_',char(fpKey)],';',...
            '\n'];
        end
    end
end





function[hdlbody,hdlsignal,rawhdlsignal]=rawForceData(hdlbody,hdlsignal,...
    inSignals,force_data,forceSignals,...
    src,txdataCnt)







    rawhdlbody=[];
    rawhdlsignal=[];

    if isempty(force_data)||(src.dataIsConstant==1)


        return;
    end



    for ii=1:length(inSignals)
        inSignal=hdlsignalfindname(inSignals{ii});
        portsltype=hdlsignalsltype(inSignal);
        vtype=hdlsignalvtype(inSignal);
        if strcmp(vtype(1:3),'reg')
            vtype=['wire ',vtype(4:end)];
        end
        isComplex=0;
        [~,rawhdlsignal(ii)]=hdlnewsignal(['rawData_',inSignals{ii}],'block',-1,isComplex,0,vtype,portsltype);
        hdlsignal=[hdlsignal,makehdlsignaldecl(rawhdlsignal(ii))];


        rawhdlbody=[rawhdlbody,'  assign '...
        ,hdlsignalname(rawhdlsignal(ii)),' = ',forceSignals{ii},'[',hdlsignalname(txdataCnt),'];\n\n'];

    end

    hdlbody=[hdlbody,rawhdlbody];

end