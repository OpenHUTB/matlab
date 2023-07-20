function[slFunctions,canvasArea,newBlocks]=createStubSLFunctions(ownerH,harnessH,slFunctions,canvasArea,cutBlockPos,onCreate)





    newBlocks=[];

    if isempty(slFunctions)
        return;
    end


    [slFcnInfo,hasCallerWithinIRT]=preprocessSLFunctions(slFunctions);
    if hasCallerWithinIRT
        errID='Sldv:Compatibility:UnsupportedSLFunctionCallFromIRTFunction';
        errMsg=getString(message(errID,getfullname(ownerH)));
        mException=MException(errID,errMsg);
        throw(mException);
    end

    harnessName=get_param(harnessH,'Name');


    stubbedSimulinkFcnInfo=struct('sid','','functionName','','functionCallers',[]);
    stubbedSimulinkFcnInfo=repmat(stubbedSimulinkFcnInfo,1,numel(slFunctions));
    numFcnsAdded=0;


    blockWidth=100;
    blockHeight=100;
    verticalGap=100;
    midX=(cutBlockPos(1)+cutBlockPos(3))/2;
    bottom=canvasArea(4)+verticalGap;





    numInportsAdded=0;
    numOutportsAdded=0;


    if~isempty(slFcnInfo.globalFunctions)
        subsysName='_HarnessGlobalStubbedFunctions';
        subsysBlockPos=[(midX-blockWidth),(bottom),(midX+blockWidth),(bottom+blockHeight)];

        isGlobal=true;
        [addedBlocks,subsysBlockPos,subsysPortNames,stubbedSimulinkFcnInfo,numFcnsAdded]=...
        createSubsystemAndAddFunctions(harnessName,subsysName,...
        subsysBlockPos,slFcnInfo.globalFunctions,isGlobal,...
        onCreate,stubbedSimulinkFcnInfo,numFcnsAdded);

        newBlocks=[newBlocks,addedBlocks];

        bottom=subsysBlockPos(4)+verticalGap;
        numInportsAdded=numInportsAdded+numel(subsysPortNames.InportNames);
        numOutportsAdded=numOutportsAdded+numel(subsysPortNames.OutportNames);
    end


    if~isempty(slFcnInfo.qualifiedScopedFunctions)
        scopedSubsystems=slFcnInfo.qualifiedScopedFunctions.keys;

        for idx=1:numel(scopedSubsystems)
            subsysName=scopedSubsystems{idx};
            subsysBlockPos=[(midX-blockWidth),(bottom),(midX+blockWidth),(bottom+blockHeight)];

            isGlobal=false;
            cuuSubsysSLFunctions=slFcnInfo.qualifiedScopedFunctions(subsysName);
            [addedBlocks,subsysBlockPos,subsysPortNames,stubbedSimulinkFcnInfo,numFcnsAdded]=...
            createSubsystemAndAddFunctions(harnessName,subsysName,...
            subsysBlockPos,cuuSubsysSLFunctions,isGlobal,onCreate,...
            stubbedSimulinkFcnInfo,numFcnsAdded);

            newBlocks=[newBlocks,addedBlocks];%#ok<AGROW> 

            bottom=subsysBlockPos(4)+verticalGap;
            numInportsAdded=numInportsAdded+numel(subsysPortNames.InportNames);
            numOutportsAdded=numOutportsAdded+numel(subsysPortNames.OutportNames);
        end
    end


    if~isempty(slFcnInfo.unqualifiedScopedFunctions)
        startPos=[(midX-blockWidth),(bottom),(midX+blockWidth),(bottom+blockHeight)];

        [addedBlocks,endPos,stubbedSimulinkFcnInfo,numFcnsAdded]=...
        createUnqualifiedSLFunctions(harnessName,startPos,...
        verticalGap,slFcnInfo.unqualifiedScopedFunctions,...
        numInportsAdded,numOutportsAdded,onCreate,...
        stubbedSimulinkFcnInfo,numFcnsAdded);

        newBlocks=[newBlocks,addedBlocks];

        bottom=endPos(2);
    end


    assert(numFcnsAdded==numel(slFunctions),...
    'Stubbed functions should have been added for all Simulink Functions');
    designModelH=ownerH;
    if~strcmp(get_param(designModelH,'Type'),'block_diagram')
        designModelH=bdroot(designModelH);
    end
    sessionObj=sldvprivate('sldvGetActiveSession',designModelH);
    if~isempty(sessionObj)

        sessionObj.addStubbedSimulinkFcnInfo(stubbedSimulinkFcnInfo);
    end


    slFunctions=[];
    canvasArea(4)=bottom;

    for idx=1:numel(newBlocks)

        set_param(newBlocks(idx),'Tag','_Harness_SLFunc_Stub_');
    end
end

function[slFcnInfo,hasCallerWithinIRT]=preprocessSLFunctions(slFunctions)












    slFcnInfo=struct('globalFunctions',[],...
    'qualifiedScopedFunctions',containers.Map('KeyType','char','ValueType','any'),...
    'unqualifiedScopedFunctions',[]);
    hasCallerWithinIRT=false;

    findOpts=Simulink.FindOptions("SearchDepth",1);
    for idx=1:numel(slFunctions)





        fcnCallers=slFunctions{idx}.callerHandles;
        for cIdx=1:numel(fcnCallers)

            blockType=get_param(fcnCallers(cIdx),'BlockType');
            if strcmp(blockType,'ModelReference')
                mdlName=get_param(fcnCallers(cIdx),'ModelName');
                callerH=Simulink.findBlocksOfType(mdlName,...
                'FunctionCaller','FunctionPrototype',slFunctions{idx}.prototype);
                callerParent=get_param(callerH,'Parent');
            else
                callerParent=get_param(fcnCallers(cIdx),'Parent');
            end
            eventListenerBlks=Simulink.findBlocksOfType(callerParent,...
            'EventListener',findOpts);
            if~isempty(eventListenerBlks)
                hasCallerWithinIRT=true;
                break;
            end
        end


        if strcmp(slFunctions{idx}.type,'global')
            slFcnInfo.globalFunctions=[slFcnInfo.globalFunctions,slFunctions{idx}];
        else

            hasQualifiedCaller=false;
            for callerIdx=1:numel(fcnCallers)
                callerH=fcnCallers(callerIdx);


                if strcmp('FunctionCaller',get_param(callerH,'BlockType'))
                    callStr=get_param(callerH,'FunctionPrototype');
                    if contains(callStr,'.')
                        key=slFunctions{idx}.scope;
                        if slFcnInfo.qualifiedScopedFunctions.isKey(key)
                            slFcnInfo.qualifiedScopedFunctions(key)=...
                            [slFcnInfo.qualifiedScopedFunctions(key),slFunctions{idx}];
                        else
                            slFcnInfo.qualifiedScopedFunctions(key)=slFunctions{idx};
                        end
                        hasQualifiedCaller=true;
                        break;
                    end
                end
            end
            if~hasQualifiedCaller
                slFcnInfo.unqualifiedScopedFunctions=...
                [slFcnInfo.unqualifiedScopedFunctions,slFunctions{idx}];
            end
        end
    end
end

function[newBlocks,subsysBlockPos,subsysPortNames,stubbedSimulinkFcnInfo,numFcnsAdded]=createSubsystemAndAddFunctions(harnessName,...
    subsysName,subsysBlockPos,slFunctions,isGlobal,onCreate,stubbedSimulinkFcnInfo,numFcnsAdded)

    newBlocks=[];

    harnessH=get_param(harnessName,'Handle');
    subsysBlockPath=[harnessName,'/',subsysName];





    findOpts=Simulink.FindOptions("SearchDepth",1);
    existingSSH=Simulink.findBlocksOfType(harnessName,...
    'SubSystem','Name',subsysName,findOpts);

    if~isempty(existingSSH)
        assert(~onCreate,'Subsystem containing stubbed Simulink Functions already exists');
        subsysH=existingSSH;



        deleteRootIO(harnessName,subsysH);
    else
        subsysH=add_block('simulink/Ports & Subsystems/Subsystem',...
        subsysBlockPath,'Position',subsysBlockPos);
        newBlocks=[newBlocks,subsysH];
    end


    deleteLines(subsysH);
    deleteBlocks(subsysH);


    [addedSLFcnBlocks,subsysPortNames]=addSLFunctionBlocks(subsysBlockPath,slFunctions,isGlobal);
    newBlocks=[newBlocks,addedSLFcnBlocks];


    assert(numel(slFunctions)==numel(addedSLFcnBlocks),...
    'Stubbed functions should have been added for all Simulink Functions');
    for idx=1:numel(addedSLFcnBlocks)
        stubbedSimulinkFcnInfo(numFcnsAdded+idx).sid=Simulink.ID.getSID(addedSLFcnBlocks(idx));
        stubbedSimulinkFcnInfo(numFcnsAdded+idx).functionName=get_param(addedSLFcnBlocks(idx),'Name');
        stubbedSimulinkFcnInfo(numFcnsAdded+idx).functionCallers=Simulink.ID.getSID(slFunctions(idx).callerHandles);
    end
    numFcnsAdded=numFcnsAdded+numel(addedSLFcnBlocks);


    sldvshareprivate('util_beautify_block',getfullname(subsysH));
    subsysBlockPos=get_param(subsysH,'Position');




    portHs=get_param(subsysH,'PortHandles');

    for i=1:numel(portHs.Inport)
        addInportBlock(harnessH,subsysPortNames.InportNames{i},...
        subsysName,portHs.Inport(i));
    end

    for i=1:numel(portHs.Outport)
        addOutportBlock(harnessH,subsysPortNames.OutportNames{i},...
        subsysName,portHs.Outport(i));
    end
end

function[addedBlocks,subsysPortNames]=addSLFunctionBlocks(parentBlockPath,slFunctionsToAdd,isGlobal)
    parentBlockH=get_param(parentBlockPath,'Handle');


    startPosX=100;
    startPosY=100;
    blockWidth=200;
    blockHeight=50;
    verticalGap=100;

    isFcnAdded=false(1,numel(slFunctionsToAdd));
    fcnBlockH=cell(1,numel(slFunctionsToAdd));



    subsysPortNames.InportNames={};
    subsysPortNames.OutportNames={};

    inportCount=0;
    outportCount=0;
    for idx=1:numel(slFunctionsToAdd)
        functionprototype=slFunctionsToAdd(idx).prototype;


        existingFcns=Simulink.harness.internal.getFunctionPrototypeStrings(bdroot(parentBlockH),parentBlockH);

        if~ismember(functionprototype,existingFcns)

            currFcnBlkName=functionprototype;
            blockPath=[parentBlockPath,'/',currFcnBlkName];

            blockPos=[startPosX,startPosY,(startPosX+blockWidth),(startPosY+blockHeight)];

            fcnBlockH{idx}=add_block('simulink/User-Defined Functions/Simulink Function',blockPath,...
            'MakeNameUnique','on','Position',blockPos);
            isFcnAdded(idx)=true;


            subsysPortNames=configSLFunctionBlock(fcnBlockH{idx},slFunctionsToAdd(idx),subsysPortNames,isGlobal);


            sldvshareprivate('util_beautify_block',getfullname(fcnBlockH{idx}));
            blockPos=get_param(fcnBlockH{idx},'Position');
            bottom=blockPos(4)+verticalGap;




            portHs=get_param(fcnBlockH{idx},'PortHandles');

            for i=1:numel(portHs.Inport)
                inportCount=inportCount+1;
                inBlkName=['In',num2str(inportCount)];
                addInportBlock(parentBlockH,inBlkName,...
                currFcnBlkName,portHs.Inport(i));
            end

            for i=1:numel(portHs.Outport)
                outportCount=outportCount+1;
                outBlkName=['Out',num2str(outportCount)];
                addOutportBlock(parentBlockH,outBlkName,...
                currFcnBlkName,portHs.Outport(i));
            end

            startPosY=bottom;
        end
    end

    addedBlocks=cell2mat(fcnBlockH(isFcnAdded));
end

function[newBlocks,endPos,stubbedSimulinkFcnInfo,numFcnsAdded]=createUnqualifiedSLFunctions(harnessName,...
    startPos,verticalGap,slFunctions,numInportsAdded,numOutportsAdded,onCreate,stubbedSimulinkFcnInfo,numFcnsAdded)

    harnessH=get_param(harnessName,'Handle');




    if~onCreate
        findOpts=Simulink.FindOptions("SearchDepth",1);
        existingFcnBlkHs=Simulink.findBlocksOfType(harnessName,'SubSystem',...
        'IsSimulinkFunction','on','Tag','_Harness_SLFunc_Stub_',findOpts);

        for idx=1:numel(existingFcnBlkHs)


            deleteRootIO(harnessName,existingFcnBlkHs(idx));
            delete_block(existingFcnBlkHs(idx));
        end
    end

    isGlobal=false;
    blockPos=startPos;
    blockHeight=startPos(4)-startPos(2);
    inportCount=numInportsAdded;
    outportCount=numOutportsAdded;

    numFcns=numel(slFunctions);
    newBlocks=zeros(1,numFcns);
    for idx=1:numFcns
        currFcnBlkName=slFunctions(idx).prototype;
        blockPath=[harnessName,'/',currFcnBlkName];

        fcnBlockH=add_block('simulink/User-Defined Functions/Simulink Function',blockPath,...
        'MakeNameUnique','on','Position',blockPos);
        newBlocks(idx)=fcnBlockH;



        subsysPortNames.InportNames={};
        subsysPortNames.OutportNames={};


        subsysPortNames=configSLFunctionBlock(fcnBlockH,slFunctions(idx),subsysPortNames,isGlobal);


        sldvshareprivate('util_beautify_block',getfullname(fcnBlockH));
        blockPos=get_param(fcnBlockH,'Position');
        bottom=blockPos(4)+verticalGap;




        portHs=get_param(fcnBlockH,'PortHandles');

        for i=1:numel(portHs.Inport)
            inportCount=inportCount+1;
            inBlkName=['In',num2str(inportCount)];
            addInportBlock(harnessH,inBlkName,...
            currFcnBlkName,portHs.Inport(i));
        end

        for i=1:numel(portHs.Outport)
            outportCount=outportCount+1;
            outBlkName=['Out',num2str(outportCount)];
            addOutportBlock(harnessH,outBlkName,...
            currFcnBlkName,portHs.Outport(i));
        end


        blockPos(2)=bottom;
        blockPos(4)=bottom+blockHeight;
    end

    endPos=blockPos;


    for idx=1:numel(newBlocks)
        stubbedSimulinkFcnInfo(numFcnsAdded+idx).sid=Simulink.ID.getSID(newBlocks(idx));
        stubbedSimulinkFcnInfo(numFcnsAdded+idx).functionName=get_param(newBlocks(idx),'Name');
        stubbedSimulinkFcnInfo(numFcnsAdded+idx).functionCallers=Simulink.ID.getSID(slFunctions(idx).callerHandles);
    end
    numFcnsAdded=numFcnsAdded+numel(newBlocks);
end

function subsysPortNames=configSLFunctionBlock(newBlockH,slFcn,subsysPortNames,isGlobal)





    set_param(newBlockH,'FunctionPrototype',slFcn.prototype);
    blockPath=[get_param(newBlockH,'Parent'),'/',get_param(newBlockH,'Name')];




    deleteLines(newBlockH);


    startPosX=150;
    endPosX=190;
    startPosY=50;
    endPosY=70;

    nArgIn=numel(slFcn.argins);
    for j=1:nArgIn
        argBlockH=Simulink.findBlocksOfType(newBlockH,'ArgIn','ArgumentName',slFcn.argins{j}.name);

        blockPos=[startPosX,(startPosY+j*50),endPosX,(endPosY+j*50)];
        set_param(argBlockH,'Position',blockPos);
        set_param(argBlockH,'OutDataTypeStr',slFcn.argins{j}.datatype);
        set_param(argBlockH,'PortDimensions',slFcn.argins{j}.dim);
        sldvshareprivate('util_beautify_block',getfullname(argBlockH));

        outBlkPath=[blockPath,'/Out',num2str(j)];
        blockPos=[(startPosX+150),(startPosY+j*50),(endPosX+150),(endPosY+j*50)];
        outH=add_block('simulink/Sinks/Out1',outBlkPath,...
        'MakeNameUnique','on','Position',blockPos);


        argBlkName=get_param(argBlockH,'Name');
        outBlkName=get_param(outH,'Name');
        add_line(newBlockH,[argBlkName,'/1'],[outBlkName,'/1']);

        subsysPortNames.OutportNames{end+1}=[slFcn.name,'_',slFcn.argins{j}.name];
    end


    startPosX=startPosX+150;
    endPosX=endPosX+150;
    startPosY=startPosY+nArgIn*50;
    endPosY=endPosY+nArgIn*50;
    nArgOut=numel(slFcn.argouts);
    for j=1:nArgOut
        argBlockH=Simulink.findBlocksOfType(newBlockH,'ArgOut','ArgumentName',slFcn.argouts{j}.name);

        blockPos=[startPosX,(startPosY+j*50),endPosX,(endPosY+j*50)];
        set_param(argBlockH,'Position',blockPos);
        set_param(argBlockH,'OutDataTypeStr',slFcn.argouts{j}.datatype);
        set_param(argBlockH,'PortDimensions',slFcn.argouts{j}.dim);
        sldvshareprivate('util_beautify_block',getfullname(argBlockH));

        inBlkPath=[blockPath,'/In',num2str(j)];
        blockPos=[(startPosX-150),(startPosY+j*50),(endPosX-150),(endPosY+j*50)];
        inH=add_block('simulink/Sources/In1',inBlkPath,...
        'MakeNameUnique','on','Position',blockPos);


        inBlkName=get_param(inH,'Name');
        argBlkName=get_param(argBlockH,'Name');
        add_line(newBlockH,[inBlkName,'/1'],[argBlkName,'/1']);

        subsysPortNames.InportNames{end+1}=[slFcn.name,'_',slFcn.argouts{j}.name];
    end


    trigPort=Simulink.findBlocksOfType(newBlockH,'TriggerPort');
    if isGlobal
        set_param(trigPort,'FunctionVisibility','global');
    else
        set_param(trigPort,'FunctionVisibility','scoped');
    end
end

function deleteLines(blkH)
    lines=find_system(blkH,'FindAll','on','type','Line');
    m=length(lines);
    for i=1:m
        delete_line(lines(i));
    end
end

function deleteBlocks(blkH)
    fOpts=Simulink.FindOptions("SearchDepth",1);
    blocks=Simulink.findBlocks(blkH,fOpts);
    m=length(blocks);
    for i=1:m
        if blocks(i)~=blkH
            delete_block(blocks(i));
        end
    end
end

function deleteRootIO(parentH,blkH)
    blkName=get_param(blkH,'Name');

    portConnectivity=get_param(blkH,'PortConnectivity');
    for idx=1:numel(portConnectivity)
        if~isempty(portConnectivity(idx).SrcBlock)&&...
            (portConnectivity(idx).SrcBlock~=-1)




            srcBlkName=get_param(portConnectivity(idx).SrcBlock,'Name');
            delete_line(parentH,[srcBlkName,'/1'],...
            [blkName,'/',portConnectivity(idx).Type]);
            delete_block(portConnectivity(idx).SrcBlock);
        end

        if~isempty(portConnectivity(idx).DstBlock)


            dstBlkName=get_param(portConnectivity(idx).DstBlock,'Name');
            delete_line(parentH,[blkName,'/',portConnectivity(idx).Type],...
            [dstBlkName,'/1']);
            delete_block(portConnectivity(idx).DstBlock);
        end
    end
end

function addInportBlock(parentH,inportName,dstBlk,dstPortH)
    portBlkWidth=20;
    portBlkHeight=8;

    dstPortPos=get_param(dstPortH,'Position');
    dstPortNum=num2str(get_param(dstPortH,'PortNumber'));

    posX=dstPortPos(1)-50;
    posY=dstPortPos(2)-portBlkHeight/2;
    inBlkPos=[posX,posY,(posX+portBlkWidth),(posY+portBlkHeight)];
    inBlkPath=[getfullname(parentH),'/',inportName];
    inH=add_block('simulink/Sources/In1',inBlkPath,...
    'MakeNameUnique','on','Position',inBlkPos);


    add_line(parentH,[inportName,'/1'],[dstBlk,'/',dstPortNum]);



    set_param(inH,'ShowName','off');
end

function addOutportBlock(parentH,outportName,srcBlk,srcPortH)
    portBlkWidth=20;
    portBlkHeight=8;

    srcPortPos=get_param(srcPortH,'Position');
    srcPortNum=num2str(get_param(srcPortH,'PortNumber'));

    posX=srcPortPos(1)+50;
    posY=srcPortPos(2)-portBlkHeight/2;
    outBlkPos=[posX,posY,(posX+portBlkWidth),(posY+portBlkHeight)];
    outBlkPath=[getfullname(parentH),'/',outportName];
    outH=add_block('simulink/Sinks/Out1',outBlkPath,...
    'MakeNameUnique','on','Position',outBlkPos);


    add_line(parentH,[srcBlk,'/',srcPortNum],[outportName,'/1']);



    set_param(outH,'ShowName','off');
end


