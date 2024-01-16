function drawTest(this,includeDut,emitMessage)

    if this.isDutWholeModel
        return;
    end

    if nargin<3
        emitMessage=true;
    end

    if nargin<2
        includeDut=false;
    end

    if emitMessage
        this.genmodeldisp(sprintf('Drawing test bench...'),3);
    end
    inFileName=get_param(this.RootNetworkName,'Parent');
    outFileName=[this.OutModelFilePrefix,inFileName];
    srcMdlObj=get_param(inFileName,'Object');

    topLevelBlks=srcMdlObj.Blocks;

    testbenchBlocks=[];

    for ii=1:numel(topLevelBlks)
        srcBlk=fixBlockName(topLevelBlks{ii});
        [isValid,isDut]=isValidTestBenchBlock(this,srcBlk,includeDut);
        if~isValid
            if isDut
                slpir.PIR2SL.drawTunableConstBlocks(this.tunablePorts,srcBlk,outFileName);
                testbenchBlocks=[testbenchBlocks,srcBlk];
            end
        end
    end
    strTestbenchBlocks=string(testbenchBlocks);
    for ii=1:numel(strTestbenchBlocks)
        srcBlk=strTestbenchBlocks(ii);
        fullBlkName=strcat(outFileName,'/',srcBlk);
        slpir.PIR2SL.connectTestpoints(this,fullBlkName,outFileName);
    end

    topLevelLines=srcMdlObj.Lines;

    if~isempty(topLevelLines)

        if any(arrayfun(@(line)strcmp(get_param(line.Handle,'object').linetype,'connection'),...
            topLevelLines))
            me=MException('hdlcoder:PIR2SL:connection',...
            message('HDLShared:hdlshared:ConnectionLines').getString);
            throwAsCaller(me);
        end
    end

    for kk=1:numel(topLevelLines)
        line=topLevelLines(kk);

        if isempty(line.SrcBlock)||line.SrcBlock==-1
            addTBLinePoints(outFileName,line);
        else
            srcPort=[fixBlockName(get_param(line.SrcBlock,'Name')),'/',line.SrcPort];
            lineProps.Name=line.Name;
            addTBLines(this,srcPort,line,lineProps,outFileName);
        end

    end
end


function addTBLines(this,srcPort,line,lineProps,outFileName)
    if~isempty(line.DstBlock)&&line.DstBlock~=-1
        dstPort=[fixBlockName(get_param(line.DstBlock,'Name')),'/',fixPortName(this,line)];
        drawTBLine(this,srcPort,dstPort,lineProps,outFileName);
    else
        if~isempty(line.Branch)

            for mm=1:numel(line.Branch)
                branch=line.Branch(mm);
                addTBLines(this,srcPort,branch,lineProps,outFileName);
            end
        else
            if line.DstBlock~=-1
                addTBLinePoints(outFileName,line,lineProps);
            end
        end
    end
end


function addTBLinePoints(outFileName,line,lineProps)

    if~isempty(line.Points)
        hL=add_line(outFileName,line.Points);

        if nargin==3
            setLineParams(hL,lineProps);
        end
    end
end


function drawTBLine(this,srcPort,dstPort,lineProps,outFileName)
    if this.AutoRoute
        hL=add_line(outFileName,srcPort,dstPort,'autorouting','on');
    else
        hL=add_line(outFileName,srcPort,dstPort);
    end
    setLineParams(hL,lineProps);
end


function setLineParams(hL,lineProps)
    srcBlk=get_param(hL,'SrcBlockHandle');
    if~ishandle(srcBlk)||~strcmpi(get_param(srcBlk,'BlockType'),'BusSelector')
        set_param(hL,'Name',lineProps.Name);
    end
end


function[valid,isDut]=isValidTestBenchBlock(this,tbBlk,includeDut)

    valid=1;
    isDut=0;

    inFileName=get_param(this.RootNetworkName,'Parent');
    outFileName=strcat(this.OutModelFilePrefix,inFileName);

    tbBlkName=[inFileName,'/',tbBlk];
    blkname=hdlfixblockname(tbBlkName);


    if~includeDut

        dutname=hdlfixblockname(this.RootNetworkName);
        if strcmp(blkname,dutname)

            valid=0;
            isDut=1;
        end
    end



    if strcmp(get_param(blkname,'MaskType'),'System Requirement Item')
        valid=0;
        return;
    end





    o=get_param(blkname,'Object');
    fn=fieldnames(o);

    if~isempty(find(strncmp('AncestorBlock',fn,13),1))&&...
        strcmpi(o.AncestorBlock,'powerlib/powergui')
        if~isempty(find_system(this.OutModelFile,'Name',tbBlk))

            delete_block([outFileName,'/',tbBlk]);
        end
    end
end


function blkName=fixBlockName(name)



    blkName=strrep(name,'/','//');
end

function port=fixPortName(this,line)

    port=line.DstPort;
    if strcmp(hdlfeature('HDLBlockAsDUT'),'on')&&this.needFullMdlGen&&...
        strcmp(getfullname(line.DstBlock),this.RootNetworkName)...
        &&(strcmp(line.DstPort,'trigger')||strcmp(line.DstPort,'enable')||strcmp(line.DstPort,'Reset'))
        phan=get_param(line.DstBlock,'PortHandles');
        port=num2str(numel(phan.Inport)+1);
    end
end

