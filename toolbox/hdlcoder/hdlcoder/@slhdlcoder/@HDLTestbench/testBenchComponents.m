function testBenchComponents(this,slConnection)





    signalNames=containers.Map;

    SLoutportHandles=slConnection.getOutportHandles;
    if~any(SLoutportHandles>0)
        this.DutHasOutputs=false;
    end
    this.OutportSnk=[];
    gp=pir;
    topNetwork=gp.getTopNetwork;
    nameIdx=0;
    for m=1:length(SLoutportHandles)
        SLportHandle=SLoutportHandles(m);
        [HDLPortName,isComplex,isRecordPort]=getOutPortDataFromBlock(topNetwork,...
        SLportHandle,nameIdx,m-1);
        [isBus,numFields]=getNumBusFields(SLportHandle,HDLPortName);
        nameIdx=nameIdx+numFields;

        for ii=1:numFields
            if isBus&&iscell(HDLPortName)
                pName=HDLPortName{ii};
            else
                pName=HDLPortName;
            end
            snkComponent=this.getComponentStruct;
            snkComponent.SLPortHandle=SLportHandle;
            snkComponent.HDLPortName{end+1}=pName;
            snkComponent.dataIsComplex=isComplex(ii);
            snkComponent.dataIsBus=isBus;
            snkComponent.isRecordPort=isRecordPort;

            if iscell(pName)

                snkComponent.loggingPortName=this.uniquifyName(pName{1},signalNames);
            else
                snkComponent.loggingPortName=this.uniquifyName(pName,signalNames);
            end
            this.OutportSnk=[this.OutportSnk,snkComponent];
        end
    end


    hDUT=get_param(slConnection.System,'handle');
    inportHandles=slConnection.getInportHandles;
    inHlen=numel(inportHandles);
    SLinportHandles=zeros(1,inHlen);




    if(this.DUTMdlRefHandle>0)
        for m=1:inHlen
            sigHier=getSignalHierarchy(inportHandles(m));
            if~isempty(sigHier)&&~isempty(sigHier.Children)&&isempty(sigHier.BusObject)
                error(message('hdlcoder:engine:TBMdlRefVirtualBus',topNetwork.SLInputSignals(m).Name,get_param(hDUT,'Name')));
            end
        end
    end

    for m=1:inHlen
        SLinportHandles(m)=getInportHandle(hDUT,m,slConnection);
    end
    this.InportSrc=[];
    nameIdx=0;


    portElems=ones(1,inHlen);
    isBus=zeros(1,inHlen);
    for m=1:inHlen
        SLportHandle=SLinportHandles(m);
        [HDLPortName,~]=getInPortDataFromBlock(topNetwork,inportHandles(m),...
        nameIdx,m-1);
        [isaBus,numFields]=getNumBusFields(SLportHandle,HDLPortName);
        nameIdx=nameIdx+numFields;
        portElems(m)=numFields;
        isBus(m)=isaBus;
    end

    nameIdx=0;
    for m=1:inHlen
        SLportHandle=SLinportHandles(m);
        if SLportHandle==-1





            nameIdx=nameIdx+portElems(m);
            continue;
        end



        srcPort=this.getComponentStruct;
        srcComponent=repmat(srcPort,1,portElems(m));
        for kk=1:portElems(m)
            [srcName,LogName]=findSrcName(SLportHandle);
            srcComponent(kk).SLBlockName=srcName;%#ok<*AGROW>
            lpn=this.uniquifyName(hdllegalnamersvd(LogName),signalNames);
            if isBus(m)
                lpn=[lpn,'_bus'];
            end
            srcComponent(kk).loggingPortName=lpn;
            srcComponent(kk).SLPortHandle=SLportHandle;
            srcComponent(kk).dataIsBus=isBus(m);



            [hasFeedBack,feedBackPort]=checkForFeedBack(this,SLportHandle);
            if hasFeedBack
                srcComponent(kk).feedBackPort=feedBackPort;
                srcComponent(kk).hasFeedBack=hasFeedBack;
            end
        end






        dupePortIdx=nameIdx;
        for jj=m:inHlen


            if SLinportHandles(jj)==SLportHandle
                [HDLPortName,isComplex,isRecordPort]=getInPortDataFromBlock(topNetwork,...
                inportHandles(jj),dupePortIdx,jj-1);
                for kk=1:portElems(m)
                    if isBus(m)&&iscell(HDLPortName)
                        pName=HDLPortName{kk};
                    else
                        pName=HDLPortName;
                    end
                    srcComponent(kk).HDLPortName{end+1}=pName;
                    srcComponent(kk).dataIsComplex=isComplex(kk);



                    srcComponent(kk).isRecordPort=isRecordPort;
                end
            end
            dupePortIdx=dupePortIdx+portElems(jj);
        end
        nameIdx=nameIdx+portElems(m);
        this.InportSrc=[this.InportSrc,srcComponent];
        SLinportHandles(SLinportHandles==SLportHandle)=-1;
    end
end


function[portnames,isComplex,isRecordPort]=getInPortDataFromBlock(topN,h_in,...
    nameIdx,typeIdx)
    sigHier=getSignalHierarchy(h_in);
    [portnames,isComplex,isRecordPort]=getInPortDataInternal(topN,sigHier,nameIdx,...
    typeIdx,[]);
end

function inportHandle=getInportHandle(block,portnum,slConnection)
    inportHandle=slConnection.getSrcBlkOutportHandle(block,portnum);
    srcBlkPath=get_param(inportHandle,'Parent');
    if strcmpi(get_param(srcBlkPath,'commented'),'through')
        if strcmp(hdlfeature('SupportCommentThrough'),'on')
            srcBlkHandle=get_param(srcBlkPath,'Handle');
            portnum=get_param(inportHandle,'PortNumber');
            inportHandle=getInportHandle(srcBlkHandle,portnum,slConnection);
        else
            error(message('hdlcoder:engine:CommentedThroughBlockUnsupportedInTB',srcBlkPath));
        end
    end
end


function[portnames,isComplex,isRecordPort]=...
    getInPortDataInternal(topN,sigHier,nameIdx,typeIdx,isComplex)
    isRecordPort=false;
    if~isempty(sigHier)&&~isempty(sigHier.Children)

        portnames={};
        hT=topN.getDUTOrigInputRecordPortType(typeIdx);
        if hT.isArrayOfRecords
            numDims=hT.getDimensions;
            flatTypes=hT.BaseType.MemberTypesFlattened;
            hT=hT.BaseType;
        else
            numDims=1;
            flatTypes=hT.MemberTypesFlattened;
        end
        currIndex=nameIdx;


        [numRecPorts,isRecordPort]=checkForRecordPort(flatTypes,hT);
        for jj=1:numDims
            for ii=1:numRecPorts
                theseNames=topN.getHDLInputPortNames(currIndex);
                tpinfo=pirgetdatatypeinfo(flatTypes(ii));
                isComplex=cat(2,isComplex,tpinfo.iscomplex);
                if tpinfo.iscomplex||tpinfo.isvector
                    theseNames={theseNames};
                end
                portnames=cat(2,portnames,theseNames);
                currIndex=currIndex+1;
            end
        end
    else

        hT=topN.getDUTOrigInputPortType(nameIdx);
        tpinfo=pirgetdatatypeinfo(hT);
        portnames=topN.getHDLInputPortNames(nameIdx);
        isComplex=tpinfo.iscomplex;
    end
end


function[portnames,isComplex,isRecordPort]=getOutPortDataFromBlock(topN,h_out,...
    nameIdx,typeIdx)
    sigHier=getSignalHierarchy(h_out);
    [portnames,isComplex,isRecordPort]=getOutPortDataInternal(topN,sigHier,nameIdx,...
    typeIdx,[]);
end


function[portnames,isComplex,isRecordPort]=...
    getOutPortDataInternal(topN,sigHier,nameIdx,typeIdx,isComplex)
    isRecordPort=false;
    if~isempty(sigHier)&&~isempty(sigHier.Children)

        portnames={};
        hT=topN.getDUTOrigOutputRecordPortType(typeIdx);
        if hT.isArrayOfRecords
            numDims=hT.getDimensions;
            flatTypes=hT.BaseType.MemberTypesFlattened;
            hT=hT.BaseType;
        else
            numDims=1;
            flatTypes=hT.MemberTypesFlattened;
        end

        [numRecPorts,isRecordPort]=checkForRecordPort(flatTypes,hT);
        currIndex=nameIdx;
        for jj=1:numDims
            for ii=1:numRecPorts
                theseNames=topN.getHDLOutputPortNames(currIndex);
                tpinfo=pirgetdatatypeinfo(flatTypes(ii));
                isComplex=cat(2,isComplex,tpinfo.iscomplex);
                if tpinfo.iscomplex||tpinfo.isvector
                    theseNames={theseNames};
                end
                portnames=cat(2,portnames,theseNames);
                currIndex=currIndex+1;
            end
        end
    else

        hT=topN.getDUTOrigOutputPortType(nameIdx);
        tpinfo=pirgetdatatypeinfo(hT);
        portnames=topN.getHDLOutputPortNames(nameIdx);
        isComplex=tpinfo.iscomplex;
    end
end


function[srcName,LogName]=findSrcName(SLHandle)
    blkPath=get_param(SLHandle,'Parent');
    blkName=get_param(blkPath,'Name');
    srcName=regexprep(regexprep(blkName,'\s',''),'-','_');
    LogName=slhdlcoder.SimulinkFrontEnd.pirGetSignalName(blkPath,SLHandle);
end


function[status,feedBackLoggingPort]=checkForFeedBack(this,inportSrcHandles)
    status=0;
    feedBackLoggingPort='';
    for i=1:length(this.OutportSnk)
        if inportSrcHandles==this.OutportSnk(i).SLPortHandle
            status=1;
            feedBackLoggingPort=this.OutportSnk(i).loggingPortName;
            break;
        end
    end
end




function sigHier=getSignalHierarchy(phan)

    bsWarn=warning('off','Simulink:blocks:StrictMsgIsSetToNonStrictSigHier');
    busWarn2=warning('off','Simulink:Bus:EditTimeBusPropFailureOutputPort');

    pcWarn=warning('off','Simulink:DataType:DataTypeObjectNotInScope');
    slw=sllastwarning;
    [lw,lwid]=lastwarn;
    sigHier=get_param(phan,'SignalHierarchy');

    [~]=warning(bsWarn.state,'Simulink:blocks:StrictMsgIsSetToNonStrictSigHier');
    [~]=warning(pcWarn.state,busWarn2.identifier);
    [~]=warning(pcWarn.state,pcWarn.identifier);
    sllastwarning(slw);
    lastwarn(lw,lwid);
end




function[isBus,numFields]=getNumBusFields(SLportHandle,HDLPortName)
    sigHier=getSignalHierarchy(SLportHandle);
    isBus=~isempty(sigHier)&&~isempty(sigHier.Children);
    if isBus&&iscell(HDLPortName)
        numFields=numel(HDLPortName);
    else
        numFields=1;
    end
end

function flattenedRecord=isFlattenedRecord(flatTypes)
    flattenedRecord=false;
    for ii=1:numel(flatTypes)
        hT=flatTypes(ii);
        if(hT.isArrayType)
            hT=hT.BaseType;
        end
        if hT.isComplexType||hT.isEnumType||(hT.isFloatType&&~targetcodegen.targetCodeGenerationUtils.isFloatingPointMode())
            flattenedRecord=true;
            break;
        end
    end
end
function[numRecPorts,isRecordPort]=checkForRecordPort(flatTypes,hT)
    hD=hdlcurrentdriver;
    isRecordPort=false;
    numRecPorts=numel(flatTypes);
    if(hD.getParameter('generaterecordtype')&&~isFlattenedRecord(flatTypes)&&~isempty(hT.getRecordName))
        numRecPorts=1;
        isRecordPort=true;
        cosimTarget=hD.getParameter('generatecosimmodel');
        generateCosimModel=~strcmpi(cosimTarget,'none');
        if(generateCosimModel)
            error(message('hdlcoder:cosim:RecordsAtDutCosim'));
        end
        svdpiTarget=hD.getParameter('generatesvdpitestbench');
        generateSvdpiTb=~strcmpi(svdpiTarget,'none');
        if(generateSvdpiTb)

            error(message('HDLLink:GenerateSVDPITestbench:RecordsAtDutSVDPI'));
        end
    end
end



