function convertToBEP(h)





    type=get_param(h,'BlockType');
    switch type
    case 'BusSelector'
        convertBusSelectorToBEP(h);
    case 'BusCreator'
        convertBusCreatorToBEP(h);
    otherwise
        error(['Unsupported block type: ',type]);
    end
end

function convertBusSelectorToBEP(h)

    s=get_param(h,'Parent');

    isOutputAsBus=strcmpi(get_param(h,'OutputAsBus'),'on');


    elements=strsplit(get_param(h,'OutputSignals'),',');


    lh=get_param(h,'LineHandles');
    olh=lh.Outport;
    dsts=arrayfun(@getDestinationExpression,olh,'UniformOutput',false);


    ph=get_param(h,'PortHandles');
    ph=ph.Outport;
    bsPortPos=arrayfun(@(h)get_param(h,'Position'),ph,'UniformOutput',false);


    pb=get_param(lh.Inport,'SrcBlockHandle');
    portNumber=get_param(pb,'Port');


    lh=get_param(s,'LineHandles');
    inputLine=lh.Inport(str2double(portNumber));


    deleteBlockAndItsLines(h);


    delete_block(pb);


    justSignals=cellfun(@(x)strrep(x,'.','_'),elements,'UniformOutput',false);
    protoBlock=getfullname(add_block('simulink/Ports & Subsystems/In Bus Element',[s,'/In Bus Element'],'MakeNameUnique','on','CreateNewPort','on','Port',portNumber,'Element',justSignals{1}));
    newBlocks=cell(1,numel(elements));
    newBlocks{1}=protoBlock;
    for i=2:numel(elements)
        newBlocks{i}=add_block(protoBlock,protoBlock,'MakeNameUnique','on','Element',justSignals{i});
    end

    if isOutputAsBus



        existingOuts=find_system(s,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Outport');
        delete_block(existingOuts);
        protoOutBlock=getfullname(add_block('simulink/Ports & Subsystems/Out Bus Element',[s,'/Out Bus Element'],'MakeNameUnique','on','CreateNewPort','on','Port',portNumber,'Element',justSignals{1}));
        newOutBlocks=cell(1,numel(elements));
        newOutBlocks{1}=protoOutBlock;
        for i=2:numel(elements)
            newOutBlocks{i}=add_block(protoOutBlock,protoOutBlock,'MakeNameUnique','on','Element',justSignals{i});
        end
    end


    protoPos=get_param(protoBlock,'Position');
    dx=protoPos(3)-protoPos(1);
    dy=protoPos(4)-protoPos(2);
    for i=1:numel(newBlocks)
        set_param(newBlocks{i},'Position',[bsPortPos{1}(1)-dx/2,bsPortPos{1}(2)-dy/2,bsPortPos{1}(1)+dx/2,bsPortPos{1}(2)+dy/2]);
    end


    for i=1:numel(newBlocks)
        if isOutputAsBus
            add_line(s,[get_param(newBlocks{i},'Name'),'/1'],[get_param(newOutBlocks{i},'Name'),'/1'],'AutoRouting','on');
        else
            if isempty(dsts{i});continue;end
            add_line(s,[get_param(newBlocks{i},'Name'),'/1'],dsts{i},'AutoRouting','on');
        end
    end


    if(inputLine~=-1)
        inputLineEndPoint=get_param(inputLine,'Points');
        inputLineEndPoint=inputLineEndPoint(end,:);
        ph=get_param(s,'PortHandles');
        ph=ph.Inport(str2double(portNumber));
        add_line(get_param(s,'Parent'),[inputLineEndPoint;get_param(ph,'Position')]);
    end
end


function convertBusCreatorToBEP(h)

    s=get_param(h,'Parent');


    o=get_param(h,'Object');
    try
        elements={o.SignalHierarchy.name};
    catch
        elements=arrayfun(@(n)sprintf('signal%d',n),1:str2double(get_param(h,'Inputs')),'UniformOutput',false);
    end


    lh=get_param(h,'LineHandles');
    ilh=lh.Inport;
    srcs=arrayfun(@getSourceExpression,ilh,'UniformOutput',false);


    ph=get_param(h,'PortHandles');
    ph=ph.Inport;
    bcPortPos=arrayfun(@(h)get_param(h,'Position'),ph,'UniformOutput',false);


    pb=get_param(lh.Outport,'DstBlockHandle');
    portNumber=get_param(pb,'Port');


    lh=get_param(s,'LineHandles');
    outputLine=lh.Outport(str2double(portNumber));


    deleteBlockAndItsLines(h);


    delete_block(pb);


    protoBlock=getfullname(add_block('simulink/Ports & Subsystems/Out Bus Element',[s,'/Out Bus Element'],'MakeNameUnique','on','CreateNewPort','on','Port',portNumber,'Element',elements{1}));
    newBlocks=cell(1,numel(elements));
    newBlocks{1}=protoBlock;
    for i=2:numel(elements)
        newBlocks{i}=add_block(protoBlock,protoBlock,'MakeNameUnique','on','Element',elements{i});
    end


    protoPos=get_param(protoBlock,'Position');
    dx=protoPos(3)-protoPos(1);
    dy=protoPos(4)-protoPos(2);
    for i=1:numel(newBlocks)
        set_param(newBlocks{i},'Position',[bcPortPos{i}(1)-dx/2,bcPortPos{i}(2)-dy/2,bcPortPos{i}(1)+dx/2,bcPortPos{i}(2)+dy/2]);
    end


    for i=1:numel(newBlocks)
        if isempty(srcs{i});continue;end
        add_line(s,srcs{i},[get_param(newBlocks{i},'Name'),'/1'],'AutoRouting','on');
    end


    outputLineEndPoint=get_param(outputLine,'Points');
    outputLineEndPoint=outputLineEndPoint(1,:);
    ph=get_param(s,'PortHandles');
    ph=ph.Outport(str2double(portNumber));
    add_line(get_param(s,'Parent'),[get_param(ph,'Position');outputLineEndPoint]);
end

function deleteBlockAndItsLines(h)
    lh=get_param(h,'LineHandles');
    fields=fieldnames(lh);
    for i=1:numel(fields)
        for ilh=lh.(fields{i})
            if ilh==-1;continue;end
            delete_line(ilh);
        end
    end
    delete_block(h);
end

function s=getDestinationExpression(lh)
    if lh==-1
        s='';
        return;
    end
    s=getBlockPortTargetExpression(get_param(lh,'DstPortHandle'));
end

function s=getSourceExpression(lh)
    if lh==-1
        s='';
        return;
    end
    s=getBlockPortTargetExpression(get_param(lh,'SrcPortHandle'));
end

function s=getBlockPortTargetExpression(ph)
    if ph==-1
        s='';
        return;
    end
    s=[get_param(get_param(ph,'ParentHandle'),'Name'),'/',num2str(get_param(ph,'PortNumber'))];
end
