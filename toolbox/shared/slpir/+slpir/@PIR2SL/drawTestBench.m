function drawTestBench(this,includeDut,emitMessage,convertModel)







    if this.isDutWholeModel
        return;
    end
    if nargin<4
        convertModel=false;
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

    inFileName=this.InModelFile;
    outFileName=this.OutModelFile;


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
            continue;
        end
        tgtBlk=srcBlk;
        srcBlkPath=[inFileName,'/',srcBlk];
        tgtBlkPath=[outFileName,'/',tgtBlk];
        copyOrigBlk(srcBlkPath,tgtBlkPath);
        copyTestpointTags(srcBlkPath,tgtBlkPath);
    end

    strTestbenchBlocks=string(testbenchBlocks);
    for ii=1:numel(strTestbenchBlocks)
        srcBlk=strTestbenchBlocks(ii);
        fullBlkName=strcat(outFileName,'/',srcBlk);
        slpir.PIR2SL.connectTestpoints(this,fullBlkName,outFileName);
    end


    addTopLevelAnnotationBlock(inFileName,outFileName);









    if(strcmp(hdlget_param(srcMdlObj.Path,'HDLDTO'),'s2h')&&convertModel)
        topLevelLines=this.insertDTCBlocksForHDLDTO;
    else
        topLevelLines=srcMdlObj.Lines;
    end


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
            addTBLinePoints(this,line);
        else
            srcPort=[fixBlockName(get_param(line.SrcBlock,'Name')),'/',line.SrcPort];
            lineProps.Name=line.Name;
            addTBLines(this,srcPort,line,lineProps);
        end
    end
end


function addTopLevelAnnotationBlock(inFileName,outFileName)

    topLevelAnnoHandles=find_system(inFileName,'SearchDepth',1,...
    'FindAll','on','type','annotation');

    for ii=1:numel(topLevelAnnoHandles)
        hSrcAnno=topLevelAnnoHandles(ii);
        annoName=fixBlockName(get(hSrcAnno,'Name'));

        notPlainText=~strcmp(get(hSrcAnno,'Interpreter'),'off');
        if notPlainText
            annoName=fixBlockName(get(hSrcAnno,'PlainText'));
        end


        if isempty(annoName)
            continue;
        end


        dupHandle=find_system(outFileName,'SearchDepth',1,...
        'FindAll','on','Name',annoName);
        if~isempty(dupHandle)
            continue;
        end


        srcAnnoPath=[inFileName,'/',annoName];
        tgtAnnoPath=[outFileName,'/',annoName];


        add_block('built-in/Note',tgtAnnoPath);


        srcHA=get_param(hSrcAnno,'HorizontalAlignment');
        set_param(tgtAnnoPath,'HorizontalAlignment',srcHA);


        set_param(tgtAnnoPath,'Position',get_param(hSrcAnno,'Position'));
        set_param(tgtAnnoPath,'Interpreter',get_param(hSrcAnno,'Interpreter'));

        srcVA=get_param(hSrcAnno,'VerticalAlignment');
        set_param(tgtAnnoPath,'VerticalAlignment',srcVA);

        if notPlainText
            annoText=get_param(srcAnnoPath,'Text');
            set_param(tgtAnnoPath,'Text',annoText);
        end

    end
end


function addTBLines(this,srcPort,line,lineProps)
    if~isempty(line.DstBlock)&&line.DstBlock~=-1

        dstPort=[fixBlockName(get_param(line.DstBlock,'Name')),'/',fixPortName(this,line)];
        drawTBLine(this,srcPort,dstPort,lineProps);
    else
        if~isempty(line.Branch)

            for mm=1:numel(line.Branch)
                branch=line.Branch(mm);
                addTBLines(this,srcPort,branch,lineProps);
            end
        else
            if line.DstBlock~=-1
                addTBLinePoints(this,line,lineProps);
            end
        end
    end
end


function addTBLinePoints(this,line,lineProps)

    if~isempty(line.Points)
        hL=add_line(this.OutModelFile,line.Points);

        if nargin==3
            setLineParams(hL,lineProps);
        end
    end
end


function drawTBLine(this,srcPort,dstPort,lineProps)
    if this.AutoRoute
        hL=add_line(this.OutModelFile,srcPort,dstPort,'autorouting','on');
    else
        hL=add_line(this.OutModelFile,srcPort,dstPort);
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

    tbBlkName=[this.InModelFile,'/',tbBlk];
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

            delete_block([this.OutModelFile,'/',tbBlk]);
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


function copyOrigBlk(srcBlkPath,tgtBlkPath)


    zorder=get_param(srcBlkPath,'ZOrder');
    if strcmp(get_param(srcBlkPath,'BlockType'),'InportShadow')
        add_block(srcBlkPath,tgtBlkPath,'copyoption','duplicate','ZOrder',zorder);
    else
        add_block(srcBlkPath,tgtBlkPath,'ZOrder',zorder);
    end
    set_param(tgtBlkPath,'ZOrder',zorder);

end


function copyTestpointTags(srcBlkPath,tgtBlkPath)



    allPorts=get_param(srcBlkPath,'PortHandles');
    allOutports=allPorts.Outport;
    allTestpointports=[];
    for jj=1:numel(allOutports)
        outportObj=get_param(allOutports(jj),'Object');
        if strcmp(outportObj.Testpoint,'on')
            allTestpointports=[allTestpointports,jj];
        end
    end
    tgtBlkH=get_param(tgtBlkPath,'handle');
    tgtBlkPorts=get_param(tgtBlkH,'PortHandles');
    tgtBlkOutports=tgtBlkPorts.Outport;
    for jj=1:numel(allTestpointports)
        portIndex=allTestpointports(jj);
        tgtPortH=tgtBlkOutports(portIndex);
        set_param(tgtPortH,'Testpoint',1);
    end
end

