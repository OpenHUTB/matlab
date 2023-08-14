function CodeGenInfo=generateCGInfo(hdlCfg,TopFunctionName,TopScriptName,DebugLevel)





    hdlDrv=hdlcurrentdriver;
    hPir=hdlDrv.PirInstance;
    isSystemC=(hdlCfg.TargetLanguage=="SystemC");

    if~isSystemC
        resourceInfo=hdlDrv.cgInfo.resourceInfo;
    end
    hCgInfo=emlhdlcoder.WorkFlow.CodeGenInfoManager.instance;
    hCgInfo.reset;

    tDir=hdlDrv.hdlGetCodegendir;

    hCgInfo.addField('topName',hdlDrv.cgInfo.topName);
    hCgInfo.addField('listOfGeneratedFiles',hdlDrv.cgInfo.hdlFiles);
    hCgInfo.addField('targetDir',tDir);

    hCgInfo.addField('baseRate',hdlDrv.cgInfo.baseRate);
    hCgInfo.addField('baseRateScaling',hdlDrv.cgInfo.baseRateScaling);
    hCgInfo.addField('TopFunctionName',TopFunctionName);
    hCgInfo.addField('TopScriptName',TopScriptName);

    if isfield(hdlDrv.cgInfo,'codegenDir')
        hCgInfo.addField('codegenDir',hdlDrv.cgInfo.codegenDir);
    end
    if~isSystemC
        hCgInfo.addField('resourceInfo',resourceInfo);
    end
    if~(isfield(hdlDrv.cgInfo,'latency'))
        hdlReportDelayBalancingInfo(hPir,false);
    end

    outputPortLatency=hdlDrv.cgInfo.latency;
    hCgInfo.addField('hdlDutPortInfo',getPortInfo(hPir,outputPortLatency));
    hCgInfo.addField('outputPortLatency',outputPortLatency);

    outputPortEnabledLatency=hdlDrv.cgInfo.enabledLatency;
    hCgInfo.addField('outputPortEnabledLatency',outputPortEnabledLatency);

    outputPortPhaseCycles=hdlDrv.cgInfo.phaseCycles;
    hCgInfo.addField('outputPortPhaseCycles',outputPortPhaseCycles);


    if~isempty(hdlCfg)
        hCgInfo.addField('codegenSettings',hdlCfg);
    end

    if DebugLevel>0

        cplpd=retrieve_cplpd(hPir);
        hCgInfo.addField('cplpd',cplpd);
    end


    streamInfo=getStreamInfo(hPir);
    hCgInfo.addField('streamInfo',streamInfo);


    if~isempty(TopScriptName)




        hdlTBGen=emlhdlcoder.HDLTestbench;
        gp=pir;
        hdlTBGen.mCEasDataValid=gp.getDutCreatesEnableBypass;
        emlDutInterface=getEmlDutInterface(hdlDrv,TopFunctionName,TopScriptName);
        hdlTBGen.testBenchComponentsEML(emlDutInterface,streamInfo);
        hdlTBGen.testBenchComponentsfromPIR;
        hdlTBGen.hdlDUTDecl;

        isTimingControllerUsed=false;
        ctxList=gp.getCtxNames;
        numModels=numel(ctxList);
        for mdlIdx=1:numModels
            p=pir(ctxList{mdlIdx});
            if(numel(p.findTimingControllerNetworks)>0)||p.isTimingControllerCtx
                isTimingControllerUsed=true;
            end
        end

        hCgInfo.addField('isTCUsed',isTimingControllerUsed);


        hdlTBGen.DutName=gp.getTopNetwork.Name;
        hdlTBGen.CopyHDLPorts;

        if~isempty(hdlTBGen.InportSrc)
            inputRate=gp.getTopNetwork.PirInputSignals(end).SimulinkRate;

            for m=1:length(hdlTBGen.InportSrc)
                hdlTBGen.InportSrc(m).HDLSampleTime=inputRate;
                hdlTBGen.InportSrc(m).SLSampleTime=inputRate;
            end
        end

        if~isempty(hdlTBGen.OutportSnk)
            outputRate=gp.getTopNetwork.PirOutputSignals(end).SimulinkRate;

            for m=1:length(hdlTBGen.OutportSnk)
                hdlTBGen.OutportSnk(m).HDLSampleTime=outputRate;
                hdlTBGen.OutportSnk(m).SLSampleTime=outputRate;
            end
        end

        hdlTBGen.getClkrateAndLatency;
        hdlTBGen.hdlsettbname(hdlDrv.getEntityTop);


        allFields=fields(hdlTBGen);
        hdlTbStruct=struct;
        for m=1:numel(allFields)
            fdname=allFields{m};
            hdlTbStruct.(fdname)=hdlTBGen.(fdname);
        end
        hCgInfo.addField('hdlTBGen',hdlTbStruct);
        emlDutInterface=rmfield(emlDutInterface,'topNtwk');
        hCgInfo.addField('emlDutInterface',emlDutInterface);
    else
        emlDutInterface=getEmlDutInterfaceWithoutTB(hdlDrv,TopFunctionName);
        hCgInfo.addField('emlDutInterface',emlDutInterface);
    end

    [entityPortList,entityRefPortList]=getPortList(hdlDrv);
    hCgInfo.addField('hdlEntityPortList',entityPortList);
    hCgInfo.addField('hdlEntityRefPortList',entityRefPortList);

    hCgInfo.addField('TopFunctionName',TopFunctionName);
    hCgInfo.addField('TopScriptName',TopScriptName);
    hCgInfo.addField('EntityNames',hPir.getEntityNames);
    hCgInfo.addField('EntityPaths',hPir.getEntityPaths);

    hCgInfo.addField('coderConstIndices',hdlDrv.cgInfo.coderConstIndices);
    hCgInfo.addField('coderConstVals',hdlDrv.cgInfo.coderConstVals);
    hCgInfo.addField('origItcs',hdlDrv.cgInfo.origItcs);
    hCgInfo.addField('IsFixPtConversionDone',hdlCfg.IsFixPtConversionDone);
    if hdlCfg.IsFixPtConversionDone
        hCgInfo.addField('fxpCfg',hdlDrv.cgInfo.fxpCfg);
        hCgInfo.addField('fxpBldDir',hdlDrv.cgInfo.fxpBldDir);
    end
    if isfield(hdlDrv.cgInfo,'actualDesignName')
        hCgInfo.addField('actualDesignName',hdlDrv.cgInfo.actualDesignName);
    end

    if isfield(hdlDrv.cgInfo,'inVals')
        hCgInfo.addField('inVals',hdlDrv.cgInfo.inVals);
    end
    if isfield(hdlDrv.cgInfo,'outVals')
        hCgInfo.addField('outVals',hdlDrv.cgInfo.outVals);
    end


    cgInfoFile=fullfile(tDir,'codegen_info.mat');
    hCgInfo.save(cgInfoFile);

    CodeGenInfo=hCgInfo.getCgInfo;
end

function cplpd=retrieve_cplpd(p)

    cplpd=struct('network',{},'preCP',{},'preLPD',{},'postCP',{},'postLPD',{});

    n=p.Networks;

    for i=1:length(n)
        s.network=n(i).RefNum;
        s.preCP=n(i).getCritPathBeforeRetiming;
        s.preLPD=n(i).getLongestPathDelayBeforeRetiming;
        s.postCP=n(i).getCritPathAfterRetiming;
        s.postLPD=n(i).getLongestPathDelayAfterRetiming;
        cplpd(end+1)=s;%#ok<AGROW>
    end
end

function portData=getPortInfo(hPir,outPortLatency)

    portData=struct('Name','','Index',0,'Direction','','Kind','','TypeInfo',{},'Rate',0,'Latency',0);

    topNtwk=hPir.getTopNetwork;
    for ii=1:topNtwk.NumberOfPirInputPorts
        pirPort=topNtwk.PirInputPorts(ii);
        pirPortSignal=pirPort.Signal;

        portInfo.Name=pirPort.Name;
        portInfo.Index=pirPort.PortIndex;
        portInfo.Direction='Input';
        portInfo.Kind=pirPort.Kind;
        portInfo.TypeInfo=pirgetdatatypeinfo(pirPortSignal.Type);
        portInfo.Rate=pirPortSignal.SimulinkRate;
        portInfo.Latency=-1;

        portData(end+1)=portInfo;%#ok<AGROW>
    end


    for ii=1:topNtwk.NumberOfPirOutputPorts
        pirPort=topNtwk.PirOutputPorts(ii);
        pirPortSignal=pirPort.Signal;
        portInfo.Name=pirPort.Name;
        portInfo.Index=pirPort.PortIndex;
        portInfo.Direction='Output';
        portInfo.Kind=pirPort.Kind;
        portInfo.TypeInfo=pirgetdatatypeinfo(pirPortSignal.Type);
        portInfo.Rate=pirPortSignal.SimulinkRate;
        portInfo.Latency=outPortLatency;
        portData(end+1)=portInfo;%#ok<AGROW>
    end
end


function emlDutInterface=getEmlDutInterface(hdlDrv,TopFunctionName,TopScriptName)

    scriptName=TopScriptName;
    if isempty(scriptName)
        emlDutInterface=[];
        return;
    end


    topFcnName=TopFunctionName;
    dbgLvl=hdlDrv.getParameter('debug');

    coder.internal.MTREEUtils.validateScript(scriptName,topFcnName,dbgLvl);

    [emlDutInterface,hN]=validateAndBuildDUTIOInfo(hdlDrv,topFcnName,dbgLvl);
    emlDutInterface.topNtwk=hN;
end


function emlDutInterface=getEmlDutInterfaceWithoutTB(hdlDrv,TopFunctionName)
    dbgLvl=hdlDrv.getParameter('debug');
    emlDutInterface=validateAndBuildDUTIOInfo(hdlDrv,TopFunctionName,dbgLvl);
end



function[emlDutInterface,hN]=validateAndBuildDUTIOInfo(hdlDrv,topFcnName,dbgLvl)
    hPir=hdlDrv.PirInstance;
    hN=hPir.getTopNetwork;
    [functionMT]=coder.internal.MTREEUtils.validateDesign(topFcnName,dbgLvl);
    [inputVars,outputVars]=coder.internal.MTREEUtils.parseDesignFcn(topFcnName,functionMT);

    coderConstIndices=hdlDrv.cgInfo.coderConstIndices;

    emlDutInterface.inportNames={};
    emlDutInterface.inputTypesInfo={};
    emlDutInterface.outportNames={};
    emlDutInterface.outputTypesInfo={};




    emlDutInterface.origInportPsuedoRecordTypes={};
    emlDutInterface.origOutportPsuedoRecordTypes={};

    portIter=0;
    for ii=1:length(inputVars)
        if any(ii==coderConstIndices)
            continue;
        end
        inputType=hN.getDUTOrigInputRecordPortType(portIter);
        psuedoType.isRecordType=inputType.isRecordType;
        if inputType.isRecordType
            memberNames=inputType.MemberNamesFlattened;
            fullNameFcn=@(fieldN)[inputVars{ii},'_',strrep(fieldN,'.','_')];
            for jj=1:length(memberNames)
                emlDutInterface.inportNames{end+1}=fullNameFcn(memberNames{jj});
                emlDutInterface.inputTypesInfo{end+1}=pirgetdatatypeinfo(inputType.MemberTypesFlattened(jj));
            end
            psuedoType.getFullName=fullNameFcn;
            psuedoType.MemberNamesFlattened=inputType.MemberNamesFlattened;
        else
            emlDutInterface.inportNames{end+1}=inputVars{ii};
            emlDutInterface.inputTypesInfo{end+1}=pirgetdatatypeinfo(inputType);
        end
        emlDutInterface.origInportPsuedoRecordTypes{end+1}=psuedoType;
        portIter=portIter+1;
    end

    for ii=1:length(outputVars)
        outputType=hN.getDUTOrigOutputRecordPortType(ii-1);
        psuedoType.isRecordType=outputType.isRecordType;
        if outputType.isRecordType
            memberNames=outputType.MemberNamesFlattened;
            fullNameFcn=@(fieldN)[outputVars{ii},'_',strrep(fieldN,'.','_')];
            for jj=1:length(memberNames)
                emlDutInterface.outportNames{end+1}=fullNameFcn(memberNames{jj});
                emlDutInterface.outputTypesInfo{end+1}=pirgetdatatypeinfo(outputType.MemberTypesFlattened(jj));
            end
            psuedoType.getFullName=fullNameFcn;
            psuedoType.MemberNamesFlattened=outputType.MemberNamesFlattened;
        else
            emlDutInterface.outportNames{end+1}=outputVars{ii};
            emlDutInterface.outputTypesInfo{end+1}=pirgetdatatypeinfo(outputType);
        end
        emlDutInterface.origOutportPsuedoRecordTypes{end+1}=psuedoType;
    end
    emlDutInterface.numIn=length(emlDutInterface.inportNames);
    emlDutInterface.numOut=length(emlDutInterface.outportNames);
end


function result=hasRefSignal(hdlDrv,SignalName)
    result=false;
    idx=hdlsignalfindname(SignalName);

    if hdlgetparameter('tbrefsignals')&&hdlisoutportsignal(idx)
        synthetic=strcmp(hdlsignalname(idx),hdlDrv.getParameter('clockenableoutputname'));
        if~synthetic&&~(idx.isClockEnable)
            result=true;
        end
    end
end


function[entityPortList,entityRefPortList]=getPortList(hdlDrv)
    entityPortList=hdlentityportnames;

    entityRefPortList=entityPortList;
    for ii=1:length(entityPortList)
        if hasRefSignal(hdlDrv,entityPortList{ii})
            entityRefPortList{ii}=entityPortList{ii};
        else
            entityRefPortList{ii}='';
        end
    end
end


function streamInfo=getStreamInfo(hPir)
    hN=hPir.getTopNetwork;
    portInfo=streamingmatrix.getStreamedPorts(hN);

    assert(isempty(portInfo.externalDelayPorts),...
    'how do we handle external delay ports in the MLHDLC test bench?');

    inNonDataIdxs=getNonDataIdxs(hN.PirInputPorts);
    outNonDataIdxs=getNonDataIdxs(hN.PirOutputPorts);





    numStreamedIn=numel(portInfo.streamedInPorts);
    streamedInPorts=repmat(struct('data',0,'valid',0,'ready',0),1,numStreamedIn);
    streamedInPortsRelative=streamedInPorts;
    for i=1:numStreamedIn
        streamedInPorts(i)=translateToStruct(portInfo.streamedInPorts(i));
        streamedInPortsRelative(i)=convertIndices(streamedInPorts(i),inNonDataIdxs,outNonDataIdxs);
    end

    numStreamedOut=numel(portInfo.streamedOutPorts);
    streamedOutPorts=repmat(struct('data',0,'valid',0,'ready',0),1,numStreamedOut);
    streamedOutPortsRelative=streamedOutPorts;
    for i=1:numStreamedOut
        streamedOutPorts(i)=translateToStruct(portInfo.streamedOutPorts(i));
        streamedOutPortsRelative(i)=convertIndices(streamedOutPorts(i),outNonDataIdxs,inNonDataIdxs);
    end

    streamInfo=struct(...
    'streamedInPorts',streamedInPorts,...
    'streamedOutPorts',streamedOutPorts,...
    'streamedInPortsRelative',streamedInPortsRelative,...
    'streamedOutPortsRelative',streamedOutPortsRelative);

    function nonDataIdxs=getNonDataIdxs(pirPorts)
        numPorts=numel(pirPorts);
        nonDataIdxs=zeros(1,numPorts);
        idx=1;
        for ii=1:numPorts
            if~strcmp(pirPorts(ii).Kind,'data')
                nonDataIdxs(idx)=ii;
                idx=idx+1;
            end
        end
        nonDataIdxs(idx:end)=[];
    end

    function outStruct=translateToStruct(streamInfoObj)



        outStruct=struct(...
        'data',streamInfoObj.data.PortIndex+1,...
        'valid',streamInfoObj.valid.PortIndex+1,...
        'ready',streamInfoObj.ready.PortIndex+1);
    end

    function outStruct=convertIndices(inStruct,validSideNonDataIdxs,readySideNonDataIdxs)


        outStruct=struct(...
        'data',inStruct.data-nnz(validSideNonDataIdxs<inStruct.data),...
        'valid',inStruct.valid-nnz(validSideNonDataIdxs<inStruct.valid),...
        'ready',inStruct.ready-nnz(readySideNonDataIdxs<inStruct.ready));
    end
end



