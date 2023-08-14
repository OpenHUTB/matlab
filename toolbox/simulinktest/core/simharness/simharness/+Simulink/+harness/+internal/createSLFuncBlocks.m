function[bottom,addedBlocks]=createSLFuncBlocks(ownerH,slFunctions,harnessH,onCreate,isSLDVCompatible)




    harnessName=get_param(harnessH,'Name');
    cutBlockPos=get_param(Simulink.ID.getHandle([harnessName,':1']),'Position');
    blockLocs=cell2mat(get_param(find_system(harnessName,'SearchDepth',1,'type','Block'),'Position'));

    top=min(blockLocs(:,2));
    bottom=max(blockLocs(:,4));
    left=min(blockLocs(:,1));
    right=max(blockLocs(:,3));

    canvasArea=[left,top,right,bottom];
    midY=(cutBlockPos(1)+cutBlockPos(3))/2;
    addedBlocks=[];

    if isSLDVCompatible&&slfeature('SLDVAutosarBSWCallersSupport')


        [slFunctions,canvasArea,addedBlocks]=sldvshareprivate('createStubSLFunctions',ownerH,harnessH,slFunctions,canvasArea,cutBlockPos,onCreate);
        assert(isempty(slFunctions),'Stubbed Simulink Function definitions should have been created for all functions');
        bottom=canvasArea(4);
        return;
    end


    if which('autosar.harness.generateBSWModule')
        if slfeature('CreateRootIOForStubSLFunctions')<1
            [slFunctions,canvasArea,addedBlocks]=autosar.harness.generateBSWModule(ownerH,harnessH,slFunctions,canvasArea,cutBlockPos,onCreate);
        end
    end
    bottom=canvasArea(4);

    globalSLFunctionSubsysH=-1;
    globalSLFunctionSubsysName='Global Stub Functions';
    if~onCreate
        blk=cell2mat(get_param(find_system(harnessName,'SearchDepth',1,'type','Block','Name',globalSLFunctionSubsysName),'Handle'));
        if~isempty(blk)
            globalSLFunctionSubsysH=blk;
        end
    end
    nFcns=length(slFunctions);
    cutBlockName=get_param(Simulink.ID.getHandle([harnessName,':1']),'Name');
    for i=1:nFcns
        scopeType=slFunctions{i}.type;

        hasQualifiedCaller=false;
        for j=1:length(slFunctions{i}.callerHandles)
            callerH=slFunctions{i}.callerHandles(j);


            if strcmp('FunctionCaller',get_param(callerH,'BlockType'))
                callStr=get_param(callerH,'FunctionPrototype');
                if~isempty(strfind(callStr,'.'))
                    hasQualifiedCaller=true;
                end
            end
        end

        if strcmp(scopeType,'global')
            createScopeSubsystem=false;
        else
            if hasQualifiedCaller
                createScopeSubsystem=true;
            else
                createScopeSubsystem=false;
            end
        end

        if slfeature('CreateRootIOForStubSLFunctions')>0
            if strcmp(scopeType,'global')

                blockPath=[harnessName,'/',slFunctions{i}.prototype];
                blockPos=[(midY-100),(bottom+50),(midY+100),(bottom+100)];
                if~hasSLFunction(harnessH,slFunctions{i}.prototype)
                    newBlockH=add_block('simulink/User-Defined Functions/Simulink Function',blockPath,...
                    'MakeNameUnique','on','Position',blockPos);
                    addedBlocks=[addedBlocks,newBlockH];
                    configSLFunctionBlock(newBlockH,slFunctions{i});



                    trigPort=find_system(newBlockH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','TriggerPort');
                    set_param(trigPort,'FunctionVisibility','global');
                    portHandles=get_param(newBlockH,'PortHandles');
                    blkHeight=max([50,24*length(portHandles.Outport),24*length(portHandles.Inport)]);
                    blockPos=[(midY-100),(bottom+50),(midY+100),(bottom+50+blkHeight)];
                    set_param(newBlockH,'Position',blockPos);
                    for j=1:length(portHandles.Inport)
                        blkName=[slFunctions{i}.name,'_',slFunctions{i}.argouts{j}.name];
                        portLoc=get_param(portHandles.Inport(j),'Position');
                        srcBlkPath=[harnessName,'/',blkName];
                        blockPos=[portLoc(1)-80,portLoc(2)-8,portLoc(1)-50,portLoc(2)+8];
                        srcBlockH=add_block('simulink/Sources/In1',srcBlkPath,...
                        'MakeNameUnique','on','Position',blockPos,'ShowName','off');
                        srcPortH=get_param(srcBlockH,'PortHandles');
                        add_line(harnessH,srcPortH.Outport(1),portHandles.Inport(j));
                    end
                    for j=1:length(portHandles.Outport)
                        blkName=[slFunctions{i}.name,'_',slFunctions{i}.argins{j}.name];
                        portLoc=get_param(portHandles.Outport(j),'Position');
                        sinkBlkPath=[harnessName,'/',blkName];
                        blockPos=[portLoc(1)+50,portLoc(2)-8,portLoc(1)+80,portLoc(2)+8];
                        sinkBlockH=add_block('simulink/Sinks/Out1',sinkBlkPath,...
                        'MakeNameUnique','on','Position',blockPos,'ShowName','off');
                        sinkPortH=get_param(sinkBlockH,'PortHandles');
                        add_line(harnessH,portHandles.Outport(j),sinkPortH.Inport(1));
                    end
                    bottom=bottom+50+blkHeight;
                end
            end
        elseif createScopeSubsystem

            if strcmp(cutBlockName,slFunctions{i}.scope)
                DAStudio.error('Simulink:Harness:ScopeNameMatchesCUTName',slFunctions{i}.prototype,slFunctions{i}.scope);
            end

            blk=cell2mat(get_param(find_system(harnessName,'SearchDepth',1,'type','Block','Name',slFunctions{i}.scope),'Handle'));
            if isempty(blk)

                blockPath=[harnessName,'/',slFunctions{i}.scope];
                blockPos=[(midY-100),(bottom+50),(midY+100),(bottom+100)];
                bottom=bottom+100;

                blk=add_block('simulink/Ports & Subsystems/Subsystem',blockPath,...
                'MakeNameUnique','on','Position',blockPos);
                addedBlocks=[addedBlocks,blk];
                deleteLines(blk);
                deleteBlocks(blk);

            elseif strcmp(get_param(blk,'BlockType'),'SubSystem')&&strcmp(get_param(blk,'Permissions'),'ReadWrite')

            else
                blockPath=[harnessName,'/',slFunctions{i}.scope];
                blockPos=[(midY-100),(bottom+50),(midY+100),(bottom+100)];
                bottom=bottom+100;

                newblk=add_block('simulink/Ports & Subsystems/Subsystem',blockPath,...
                'MakeNameUnique','on','Position',blockPos);
                addedBlocks=[addedBlocks,newblk];
                deleteLines(newblk);
                deleteBlocks(newblk);

                names=getTopLevelBlockNames(harnessH);
                unqName=matlab.lang.makeUniqueStrings(slFunctions{i}.scope,names);
                set_param(blk,'Name',unqName);
                blk=newblk;
                set_param(blk,'Name',slFunctions{i}.scope);
            end


            SSblockLocs=get_param(find_system(blk,'SearchDepth',1,'type','Block','BlockType','SubSystem','IsSimulinkFunction','on'),'Position');
            if iscell(SSblockLocs)
                SSblockLocs=cell2mat(SSblockLocs);
            end
            if isempty(SSblockLocs)
                SSbottom=0;
            else
                SSbottom=max(SSblockLocs(:,4));
            end

            blockPath=[harnessName,'/',slFunctions{i}.scope,'/',slFunctions{i}.prototype];
            blockPos=[100,(SSbottom+50),300,(SSbottom+100)];
            if~hasSLFunction(blk,slFunctions{i}.prototype)
                newBlockH=add_block('simulink/User-Defined Functions/Simulink Function',blockPath,...
                'MakeNameUnique','on','Position',blockPos);
                addedBlocks=[addedBlocks,newBlockH];
                configSLFunctionBlock(newBlockH,slFunctions{i});



                trigPort=find_system(newBlockH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','TriggerPort');
                if strcmp(scopeType,'global')
                    set_param(trigPort,'FunctionVisibility','global');
                else
                    set_param(trigPort,'FunctionVisibility','scoped');
                end
            end

        elseif~strcmp(scopeType,'global')

            blockPath=[harnessName,'/',slFunctions{i}.prototype];
            blockPos=[(midY-100),(bottom+50),(midY+100),(bottom+100)];
            bottom=bottom+100;
            if~hasSLFunction(harnessH,slFunctions{i}.prototype)
                newBlockH=add_block('simulink/User-Defined Functions/Simulink Function',blockPath,...
                'MakeNameUnique','on','Position',blockPos);
                addedBlocks=[addedBlocks,newBlockH];
                configSLFunctionBlock(newBlockH,slFunctions{i});



                trigPort=find_system(newBlockH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','TriggerPort');
                set_param(trigPort,'FunctionVisibility','scoped');
            end
        else
            if globalSLFunctionSubsysH>0
                SSblockLocs=get_param(find_system(globalSLFunctionSubsysH,'SearchDepth',1,'type','Block','BlockType','SubSystem','IsSimulinkFunction','on'),'Position');
                if iscell(SSblockLocs)
                    SSblockLocs=cell2mat(SSblockLocs);
                end
                if isempty(SSblockLocs)
                    SSbottom=0;
                else
                    SSbottom=max(SSblockLocs(:,4));
                end
            else

                blockPath=[harnessName,'/',globalSLFunctionSubsysName];
                blockPos=[(midY-100),(bottom+50),(midY+100),(bottom+100)];
                bottom=bottom+100;

                globalSLFunctionSubsysH=add_block('simulink/Ports & Subsystems/Subsystem',blockPath,...
                'Position',blockPos);
                addedBlocks=[addedBlocks,globalSLFunctionSubsysH];
                deleteLines(globalSLFunctionSubsysH);
                deleteBlocks(globalSLFunctionSubsysH);

                SSbottom=0;
            end

            blockPath=[harnessName,'/',globalSLFunctionSubsysName,'/',slFunctions{i}.prototype];
            blockPos=[100,(SSbottom+50),300,(SSbottom+100)];
            if~hasSLFunction(harnessH,slFunctions{i}.prototype)&&~hasSLFunction(globalSLFunctionSubsysH,slFunctions{i}.prototype)
                bottom=bottom+100;
                newBlockH=add_block('simulink/User-Defined Functions/Simulink Function',blockPath,...
                'MakeNameUnique','on','Position',blockPos);
                addedBlocks=[addedBlocks,newBlockH];%#ok<*AGROW> 
                configSLFunctionBlock(newBlockH,slFunctions{i});



                trigPort=find_system(newBlockH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','TriggerPort');
                if strcmp(scopeType,'global')
                    set_param(trigPort,'FunctionVisibility','global');
                else
                    set_param(trigPort,'FunctionVisibility','scoped');
                end
            end
        end
    end

    for i=1:length(addedBlocks)
        set_param(addedBlocks(i),'Tag','_SLT_SLFunc_Stub_');
    end

end


function configSLFunctionBlock(newBlockH,slFcn)
    blockPath=[get_param(newBlockH,'Parent'),'/',get_param(newBlockH,'Name')];

    set_param(newBlockH,'FunctionPrototype',slFcn.prototype);
    deleteLines(newBlockH);
    nArgIn=length(slFcn.argins);
    for j=1:nArgIn


        argBlockH=find_system(newBlockH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ArgIn','ArgumentName',slFcn.argins{j}.name);

        blockPos=[250,(10+j*50),280,(30+j*50)];
        set_param(argBlockH,'Position',blockPos);
        set_param(argBlockH,'OutDataTypeStr',slFcn.argins{j}.datatype);
        set_param(argBlockH,'PortDimensions',slFcn.argins{j}.dim);

        if slfeature('CreateRootIOForStubSLFunctions')>0
            termBlkPath=[blockPath,'/Out'];
            blockPos=[350,(10+j*50),380,(30+j*50)];
            termH=add_block('simulink/Sinks/Out1',termBlkPath,...
            'MakeNameUnique','on','Position',blockPos);
        else
            termBlkPath=[blockPath,'/Term'];
            blockPos=[350,(10+j*50),380,(30+j*50)];
            termH=add_block('simulink/Sinks/Terminator',termBlkPath,...
            'MakeNameUnique','on','Position',blockPos);

        end

        argBlkName=get_param(argBlockH,'Name');
        termBlkName=get_param(termH,'Name');
        add_line(newBlockH,[argBlkName,'/1'],[termBlkName,'/1']);
    end

    nArgOut=length(slFcn.argouts);
    for j=1:nArgOut



        argBlockH=find_system(newBlockH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ArgOut','ArgumentName',slFcn.argouts{j}.name);
        blockPos=[150,(10+j*50),180,(30+j*50)];
        set_param(argBlockH,'Position',blockPos);
        set_param(argBlockH,'OutDataTypeStr',slFcn.argouts{j}.datatype);
        set_param(argBlockH,'PortDimensions',slFcn.argouts{j}.dim);

        isBus=strncmp(slFcn.argouts{j}.datatype,'Bus: ',5);
        if slfeature('CreateRootIOForStubSLFunctions')>0
            groundBlkPath=[blockPath,'/In'];
            blockPos=[50,(10+j*50),80,(30+j*50)];
            groundH=add_block('simulink/Sources/In1',groundBlkPath,...
            'MakeNameUnique','on','Position',blockPos);
            groundBlkName=get_param(groundH,'Name');
            argBlkName=get_param(argBlockH,'Name');
            add_line(newBlockH,[groundBlkName,'/1'],[argBlkName,'/1']);
        elseif~isBus
            groundBlkPath=[blockPath,'/Ground'];
            blockPos=[50,(10+j*50),80,(30+j*50)];
            groundH=add_block('simulink/Sources/Ground',groundBlkPath,...
            'MakeNameUnique','on','Position',blockPos);
            groundBlkName=get_param(groundH,'Name');
            argBlkName=get_param(argBlockH,'Name');
            add_line(newBlockH,[groundBlkName,'/1'],[argBlkName,'/1']);
        else

            subsysBlkPath=[blockPath,'/Ground'];
            blockPos=[50,(10+j*50),80,(30+j*50)];
            subsysH=add_block('simulink/Ports & Subsystems/Subsystem',subsysBlkPath,...
            'MakeNameUnique','on','Position',blockPos);
            deleteLines(subsysH);
            deleteBlocks(subsysH);

            groundBlkPath=[blockPath,'/',get_param(subsysH,'Name'),'/Ground'];
            blockPos=[50,50,80,80];
            groundBlkH=add_block('simulink/Sources/Ground',groundBlkPath,...
            'MakeNameUnique','on','Position',blockPos);
            outportBlkPath=[blockPath,'/',get_param(subsysH,'Name'),'/Out'];
            blockPos=[150,50,180,80];
            outportBlkH=add_block('simulink/Sinks/Out1',outportBlkPath,...
            'MakeNameUnique','on','Position',blockPos);
            set_param(outportBlkH,'OutDataTypeStr',slFcn.argouts{j}.datatype,'PortDimensions',slFcn.argouts{j}.dim);

            pH_src=get_param(groundBlkH,'PortHandles');
            pH_dst=get_param(outportBlkH,'PortHandles');
            add_line(subsysH,pH_src.Outport(1),pH_dst.Inport(1));

            pH_src=get_param(subsysH,'PortHandles');
            pH_dst=get_param(argBlockH,'PortHandles');
            add_line(newBlockH,pH_src.Outport(1),pH_dst.Inport(1));
        end
    end


end

function deleteLines(blkH)


    lines=find_system(blkH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','type','Line');
    m=length(lines);
    for i=1:m
        delete_line(lines(i));
    end

end

function deleteBlocks(blkH)


    blocks=find_system(blkH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','type','Block');
    m=length(blocks);
    for i=1:m
        if blocks(i)~=blkH
            delete_block(blocks(i));
        end
    end

end

function res=hasSLFunction(sysH,functionprototype)
    if isa(get_param(sysH,'Object'),'Simulink.BlockDiagram')
        fcnList=Simulink.harness.internal.getFunctionPrototypeStrings(sysH,-1);
    else
        fcnList=Simulink.harness.internal.getFunctionPrototypeStrings(bdroot(sysH),sysH);
    end
    res=ismember(functionprototype,fcnList);
end

function names=getTopLevelBlockNames(sysH)
    names=get_param(find_system(sysH,'SearchDepth',1,'type','Block'),'Name');
    if~iscell(names)
        names={names};
    end
end


